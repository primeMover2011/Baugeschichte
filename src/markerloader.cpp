#include "markerloader.h"

#include <QDateTime>
#include <QDebug>
#include <QElapsedTimer>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QtConcurrent>

#include <limits>

MarkerLoader::MarkerLoader(QObject* parent)
    : QObject(parent)
    , m_latitude(-std::numeric_limits<double>::max())
    , m_longitude(-std::numeric_limits<double>::max())
    , m_radius(-1.0)
    , m_loadAll(false)
    , m_manager(new QNetworkAccessManager(this))
    , m_loading(false)
{
    m_lazyLoadTimer.setSingleShot(true);
    m_lazyLoadTimer.setInterval(100); // 100 ms
    connect(&m_lazyLoadTimer, &QTimer::timeout, this, &MarkerLoader::loadMarkers);

    connect(m_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(poisFinished(QNetworkReply*)));
}

double MarkerLoader::latitude() const
{
    return m_latitude;
}

double MarkerLoader::longitude() const
{
    return m_longitude;
}

void MarkerLoader::setLocation(double latitude, double longitude)
{
    if (std::abs(latitude - m_latitude) < 1e-12 && std::abs(longitude - m_longitude) < 1e-12) {
        return;
    }

    m_latitude = latitude;
    m_longitude = longitude;

    emit latitudeChanged(m_latitude);
    emit longitudeChanged(m_longitude);
    emit locationChanged(m_latitude, m_longitude);

    m_lazyLoadTimer.start();
}

double MarkerLoader::radius() const
{
    return m_radius;
}

void MarkerLoader::setRadius(double radius)
{
    if (std::abs(radius - m_radius) < 1e-12) {
        return;
    }

    m_radius = radius;
    emit radiusChanged(radius);

    m_lazyLoadTimer.start();
}

bool MarkerLoader::loadAll() const
{
    return m_loadAll;
}

void MarkerLoader::setLoadAll(bool loadAll)
{
    if (loadAll == m_loadAll) {
        return;
    }

    m_loadAll = loadAll;
    emit loadAllChanged(m_loadAll);

    m_lazyLoadTimer.start();
}

bool MarkerLoader::loading() const
{
    return m_loading;
}

void MarkerLoader::loadMarkers()
{
    static double COORD_LIMIT = -9e12;
    if (m_latitude < COORD_LIMIT || m_longitude < COORD_LIMIT || m_radius < 0.0) {
        return;
    }

    QString locationRequest
        = QString("http://baugeschichte.at/app/v1/getData.php?action=getBuildingsBoxed&lat=%1&lon=%2&radius=")
              .arg(m_latitude, 0, 'f', 7)
              .arg(m_longitude, 0, 'f', 7);
    QString theRequest4Pois = locationRequest + QString::number(m_radius, 'f', 7);
    if (m_loadAll) {
        theRequest4Pois = theRequest4Pois % "&all=1";
    }

    //    qDebug() << theRequest4Pois;
    QNetworkRequest request = QNetworkRequest(QUrl(theRequest4Pois));
    m_requests.append(request);
    m_manager->get(request);

    setLoading(!m_requests.isEmpty());
}

void MarkerLoader::poisFinished(QNetworkReply* theReply)
{
    QtConcurrent::run(this, &MarkerLoader::createModelAsync, theReply);

    const QNetworkRequest& request = theReply->request();
    m_requests.removeOne(request);
    if (!m_requests.empty()) {
        m_manager->get(m_requests.first());
    }

    setLoading(!m_requests.isEmpty());
}

void MarkerLoader::createModelAsync(QNetworkReply* theReply)
{
    //    qDebug() << Q_FUNC_INFO;
    QString theResponse;
    if (theReply) {
        if (theReply->error() == QNetworkReply::NoError) {
            const qint64 available = theReply->bytesAvailable();
            if (available > 0) {
                const QByteArray buffer = QString::fromUtf8(theReply->readAll()).toLatin1();
                QJsonParseError anError;
                QJsonDocument aDoc = QJsonDocument::fromJson(buffer, &anError);
                if (QJsonParseError::NoError != anError.error) {
                    qDebug() << anError.errorString();
                    return;
                }

                if (!aDoc.isObject()) {
                    qDebug() << "no object..." << aDoc.toVariant();
                }
                QJsonDocument doc;
                {
                    QJsonObject anInfoObject = aDoc.object();
                    QJsonArray theValueArray = anInfoObject["payload"].toArray();
                    QVector<HouseMarker> markers;
                    markers.reserve(theValueArray.size());
                    foreach (const QJsonValue& theValue, theValueArray) {
                        HouseMarker aHouseTrail;
                        QJsonObject anObj = theValue.toObject();
                        aHouseTrail.setDbId(anObj["id"].toInt());
                        aHouseTrail.setHouseTitle(anObj["title"].toString());
                        aHouseTrail.setTheLocation(QGeoCoordinate(anObj["lat"].toDouble(), anObj["lon"].toDouble()));

                        doc.setArray(anObj["cats"].toArray());

                        aHouseTrail.setCategories(doc.toJson());
                        markers.push_back(aHouseTrail);
                    }

                    emit newHousetrail(markers);
                }
            } else
                theResponse = "empty";
        } else {
            theResponse = tr("Error: %1 status: %2")
                              .arg(theReply->errorString(),
                                  theReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString());
        }

        qDebug() << "code: " << theReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString()
                 << " response: " << theResponse;
        theReply->deleteLater();
    }
}

void MarkerLoader::setLoading(bool loading)
{
    if (loading == m_loading) {
        return;
    }

    m_loading = loading;
    emit loadingChanged(m_loading);
}
