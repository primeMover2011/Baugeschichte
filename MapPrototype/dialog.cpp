#include "dialog.h"
#include <QtConcurrent>


void Dialog::setInfotext(QString aText)
{
    m_infotext = aText;
    emit infotextChanged(m_infotext);
}

void Dialog::getAllPois()
{
    QString theRequest4Pois("http://baugeschichte.at/app/v1/getData.php?action=getBuildingsBoxed&lat=47&lon=15&radius=1");
    m_manager->get(QNetworkRequest(QUrl(theRequest4Pois)));
}

void Dialog::poisFinished(QNetworkReply *theReply)
{
    QtConcurrent::run(this, &Dialog::createModelAsync, theReply);
}
void Dialog::createModelAsync(QNetworkReply *theReply)
{
    qDebug()<<"poisFinished";
    QString theResponse;
    if (theReply)
    {
        if (theReply->error() == QNetworkReply::NoError)
        {
            const int available = theReply->bytesAvailable();
            QUrl theUrl = theReply->url();
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
                    //int i = 0;
                    foreach (const QJsonValue& theValue, theValueArray) {
                        //if (i++ > 30) break;
                        HouseTrail* aHouseTrail = new HouseTrail();
                        QJsonObject anObj = theValue.toObject();
                        aHouseTrail->setDbId(anObj["id"].toInt());
                        aHouseTrail->setHouseTitle(anObj["title"].toString());
                        aHouseTrail->setTheLocation(QGeoCoordinate(anObj["lat"].toDouble(),anObj["lon"].toDouble()));


                        doc.setArray(anObj["cats"].toArray());

                        aHouseTrail->setCategories(doc.toJson());
                        emit newHousetrail(aHouseTrail);
                    }


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


Dialog::Dialog(HousetrailModel *aHouseTrails, QObject *parent)
    : QObject(parent), m_HouseTrailImages(aHouseTrails)
{
    m_source = QGeoPositionInfoSource::createDefaultSource(this);
    if (m_source)
    {
        connect(m_source, SIGNAL(positionUpdated(QGeoPositionInfo)),
                this, SLOT(positionUpdated(QGeoPositionInfo)));

    }

    m_manager = new QNetworkAccessManager(this);
    //m_manager->setAtt
    connect(m_manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(poisFinished(QNetworkReply*)));
    connect(this, SIGNAL(newHousetrail(HouseTrail*)),
            this, SLOT(onNewHouseTrail(HouseTrail*)));
    // m_manager->get(QNetworkRequest(QUrl("http://www.google.com")));

    setPoiID(-1);
}
