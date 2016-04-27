#include "dialog.h"
#include "Geohash.hpp"

#include <QElapsedTimer>
#include <QDateTime>
#include <QDebug>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QtConcurrent>

Dialog::Dialog(HousetrailModel *aHouseTrails, QObject *parent)
    : QObject(parent)
    , m_source(QGeoPositionInfoSource::createDefaultSource(this))
    , m_manager (new QNetworkAccessManager(this))
    , m_HouseTrailImages(aHouseTrails)
    , m_loading(false)
{
    if (m_source)
    {
        connect(m_source, SIGNAL(positionUpdated(QGeoPositionInfo)),
                this, SLOT(positionUpdated(QGeoPositionInfo)));
    }

    connect(m_manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(poisFinished(QNetworkReply*)));
    connect(this, SIGNAL(newHousetrail(QVector<HouseTrail>)),
            m_HouseTrailImages, SLOT(append(QVector<HouseTrail>)));

    setPoiID(-1);
}

void Dialog::setInfotext(QString aText)
{
    if (aText == m_infotext)
    {
        return;
    }
    m_infotext = aText;
    emit infotextChanged(m_infotext);
}

QString Dialog::infotext() const
{
    return m_infotext;
}

void Dialog::setPoiID(const int apoiID)
{
    if (apoiID == m_poiID) {
        return;
    }
    m_poiID = apoiID;
    emit poiIDChanged(m_poiID);
}

int Dialog::poiID() const
{
    return m_poiID;
}

double Dialog::latitude() const
{
    return m_latitude;
}

double Dialog::longitude() const
{
    return m_longitude;
}

void Dialog::setDetailTitle(const QString aDetailTitle)
{
    if (aDetailTitle == m_detailTitle) {
        return;
    }
    m_detailTitle = aDetailTitle;
    emit detailTitleChanged(m_detailTitle);
}

QString Dialog::detailTitle() const
{
    return m_detailTitle;
}

bool Dialog::loading() const
{
    return m_loading;
}

void Dialog::getAllPois()
{
    QString theRequest4Pois("http://baugeschichte.at/app/v1/getData.php?action=getBuildingsBoxed&lat=47&lon=15&radius=1");
    QNetworkRequest request1 = QNetworkRequest(QUrl(theRequest4Pois));
    m_requests.append(request1);
    m_manager->get(request1);

    setLoading(!m_requests.isEmpty());
}

void Dialog::getPois(double lat, double lon, double radius, double zoomlevel)
{
    QString locationRequest = QString("http://baugeschichte.at/app/v1/getData.php?action=getBuildingsBoxed&lat=%1&lon=%2&radius=")
            .arg(lat,0,'f',7)
            .arg(lon,0,'f',7);
    QString theRequest4Pois = locationRequest + QString::number(radius, 'f', 7);
    if (zoomlevel > 17)
        theRequest4Pois = theRequest4Pois % "&all=1";

//    qDebug() << theRequest4Pois;
    QNetworkRequest request = QNetworkRequest(QUrl(theRequest4Pois));
    m_requests.append(request);
    m_manager->get(request);

    setLoading(!m_requests.isEmpty());
}

QString Dialog::getGeoHashFromLocation(QGeoCoordinate theLocation, int thePrecision)
{   if (thePrecision < 1) thePrecision = 1;
    if (thePrecision > 12) thePrecision = 12;

    std::string aGeoHash;
    GeographicLib::Geohash::Forward(theLocation.latitude(),theLocation.longitude(),thePrecision,aGeoHash);
    return QString::fromStdString(aGeoHash);
}

QGeoCoordinate Dialog::getLocationFromGeoHash(QString theGeoHash)
{
    //if (thePrecision < 1) thePrecision = 1;
    //if (thePrecision > 12) thePrecision = 12;

    std::string aGeoHash = theGeoHash.toStdString();
    double lat, lon;
    int theLen;

    GeographicLib::Geohash::Reverse(aGeoHash, lat,lon,theLen);
    return QGeoCoordinate(lat, lon);
}

void Dialog::locateMe() const
{
    if (m_source)
    {
        m_source->startUpdates();
    }
}

void Dialog::slotError(QNetworkReply::NetworkError anError)
{
    Q_UNUSED(anError)
    qDebug() << "Networkerror";
}

void Dialog::httpFinished()
{
    qDebug() << "Http finished ";
}

void Dialog::replyFinished(QNetworkReply *theReply)
{
    qDebug()<<"replyFinished";
    QString theResponse;
    if (theReply)
    {
        if (theReply->error() == QNetworkReply::NoError)
        {
            const int available = theReply->bytesAvailable();
            if (available > 0)
            {
                const QByteArray buffer = theReply->readAll();
                QJsonParseError anError;
                QJsonDocument aDoc = QJsonDocument::fromJson(buffer, &anError);
                if (aDoc.isObject())
                {
                    QJsonObject anInfoObject=aDoc.object();
                    setInfotext(anInfoObject["title"].toString());
                    setDetailTitle(anInfoObject["text"].toString());
                    QJsonArray anImageArray = anInfoObject["images"].toArray();
                    m_HouseTrailImages->clear();
                    /*                               foreach (const QJsonValue& value, anImageArray) {
                                   QJsonObject obj = value.toObject();
                                   m_HouseTrailImages->addHousetrail(HousetrailImages(obj["id"].toString(),
                                                                     obj["name"].toString(),
                                           obj["url"].toString(),
                                           obj["jahr"].toString(),
                                           obj["beschreibung"].toString()));
                                   qDebug() << "jsonarray: " << obj["url"].toString();
                               }
                               if (m_HouseTrailImages->rowCount() < 1)
                                   m_HouseTrailImages->addHousetrail(HousetrailImages("noID","noName","http://www.baugeschichte.at/images/4/4d/Dummy_Kein_Bild.png","---","---"));
*/
                }
            }
            else
                theResponse="empty";
        }
        else
        {
            theResponse =  tr("Error: %1 status: %2").arg(theReply->errorString(),
                                                          theReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString());
        }

        qDebug()<<"code: "<<
                  theReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString() <<
                  " response: "<< theResponse;
        theReply->deleteLater();
    }
}

void Dialog::poiSelected(const int aPoiId)
{
    //setInfotext(QString::number(aPoiId));
    setPoiID(aPoiId);
    qDebug() << "Got poi" << aPoiId;

    if (aPoiId < 0) return;
    QString theGrazWikiUrl = QString("%1%2").arg("http://grazwiki.zobl.at/api/get_poi.php?poiId=", QString::number(aPoiId));

    qDebug() << "Got URL" << theGrazWikiUrl;
    QNetworkReply* theReply = m_manager->get(QNetworkRequest(QUrl(theGrazWikiUrl)));
    //  theReply->

    connect(theReply,SIGNAL(finished()),
            this, SLOT(httpFinished()));
}

void Dialog::poisFinished(QNetworkReply *theReply)
{
    QtConcurrent::run(this, &Dialog::createModelAsync, theReply);

    const QNetworkRequest& request = theReply->request();
    m_requests.removeOne(request);
    if (!m_requests.empty())
    {
        m_manager->get(m_requests.first());
    }

    setLoading(!m_requests.isEmpty());
}

void Dialog::createModelAsync(QNetworkReply *theReply)
{
    qDebug()<<"poisFinished";
    QString theResponse;
    if (theReply)
    {
        if (theReply->error() == QNetworkReply::NoError)
        {
            const qint64 available = theReply->bytesAvailable();
            if (available > 0)
            {
                const QByteArray buffer = QString::fromUtf8(theReply->readAll()).toLatin1();
                QJsonParseError anError;
                QJsonDocument aDoc = QJsonDocument::fromJson(buffer, &anError);
                if (QJsonParseError::NoError != anError.error)
                {
                    qDebug() << anError.errorString();
                    return;
                }

                if (!aDoc.isObject())
                {
                    qDebug() << "no object..." << aDoc.toVariant();
                }
                QJsonDocument doc;
                {
                    QJsonObject anInfoObject=aDoc.object();
                    QJsonArray theValueArray = anInfoObject["payload"].toArray();
                    QVector<HouseTrail> markers;
                    markers.reserve(theValueArray.size());
                    foreach (const QJsonValue& theValue, theValueArray) {
                        HouseTrail aHouseTrail;
                        QJsonObject anObj = theValue.toObject();
                        aHouseTrail.setDbId(anObj["id"].toInt());
                        aHouseTrail.setHouseTitle(anObj["title"].toString());
                        aHouseTrail.setTheLocation(QGeoCoordinate(anObj["lat"].toDouble(),anObj["lon"].toDouble()));

                        doc.setArray(anObj["cats"].toArray());

                        aHouseTrail.setCategories(doc.toJson());
                        markers.push_back(aHouseTrail);
                    }

                    emit newHousetrail(markers);

/*             QJsonObject anInfoObject=aDoc.object();
                    setInfotext(anInfoObject["title"].toString());
                    setDetailTitle(anInfoObject["text"].toString());
                    QJsonArray anImageArray = anInfoObject["images"].toArray();
                    m_HouseTrailImages->clear();
                    foreach (const QJsonValue& value, anImageArray) {
                        QJsonObject obj = value.toObject();
                        m_HouseTrailImages->addHousetrail(HousetrailImages(obj["id"].toString(),
                                                          obj["name"].toString(),
                                obj["url"].toString(),
                                obj["jahr"].toString(),
                                obj["beschreibung"].toString()));
                        qDebug() << "jsonarray: " << obj["url"].toString();
                    }
                    if (m_HouseTrailImages->rowCount() < 1)
                        m_HouseTrailImages->addHousetrail(HousetrailImages("noID","noName","http://www.baugeschichte.at/images/4/4d/Dummy_Kein_Bild.png","---","---"));
*/
                }
            }
            else
                theResponse="empty";
        }
        else
        {
            theResponse =  tr("Error: %1 status: %2").arg(theReply->errorString(),
                                                          theReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString());
        }

        //                  QJson::Parser parser;
        //                  bool ok;

        qDebug()<<"code: "<<
                  theReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString() <<
                  " response: "<< theResponse;
        theReply->deleteLater();
    }
}

void Dialog::httpReadyRead(QNetworkReply *reply){
    Q_UNUSED(reply)
    qDebug() << "Http ready read ";
}

void Dialog::positionUpdated(const QGeoPositionInfo &info)
{
    qDebug() << "Position updated:" << info;
    m_latitude = info.coordinate().latitude();
    m_longitude = info.coordinate().longitude();
    if (m_source)
    {
        m_source->stopUpdates();
    }

    emit latitudeChanged(m_latitude);
    emit longitudeChanged(m_longitude);
    emit locationChanged(m_longitude, m_latitude);
}

void Dialog::setLoading(bool loading)
{
    if (loading == m_loading) {
        return;
    }

    m_loading = loading;
    emit loadingChanged(m_loading);
}
