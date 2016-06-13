#ifndef MARKERLOADER
#define MARKERLOADER

#include "housetrailimages.h"

#include <QObject>
#include <QGeoCoordinate>
#include <QList>
#include <QNetworkReply>
#include <QTimer>
#include <QVector>

/**
 * Loads markers for it's given position and radius
 * The loading is triggered (after a short delay) automaticly when the position/radius changes
 */
class MarkerLoader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double latitude READ latitude /*WRITE setLatitude*/ NOTIFY latitudeChanged)
    Q_PROPERTY(double longitude READ longitude /*WRITE setLongitude*/ NOTIFY longitudeChanged)
    Q_PROPERTY(double radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(bool loadAll READ loadAll WRITE setLoadAll NOTIFY loadAllChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit MarkerLoader(QObject *parent = 0);

    double latitude() const;
    double longitude() const;
    Q_INVOKABLE void setLocation(double latitude, double longitude);

    double radius() const;
    void setRadius(double radius);

    bool loadAll() const;
    void setLoadAll(bool loadAll);

    bool loading() const;

    Q_INVOKABLE QString getGeoHashFromLocation(QGeoCoordinate theLocation, int thePrecision);
    Q_INVOKABLE QGeoCoordinate getLocationFromGeoHash(QString theGeoHash);

signals:
    void latitudeChanged(double);
    void longitudeChanged(double);
    void locationChanged(double, double);
    void radiusChanged(double);
    void newHousetrail(QVector<HouseTrail> aNewHouseTrail);
    void loadingChanged(bool loading);

    void loadAllChanged(bool loadAll);

private slots:
    void loadMarkers();
    void poisFinished(QNetworkReply* theReply);
    void createModelAsync(QNetworkReply *theReply);

private:
    void setLoading(bool loading);

    double m_latitude;
    double m_longitude;
    double m_radius;
    bool m_loadAll;

    QNetworkAccessManager* m_manager;
    bool m_loading;

    QList<QNetworkRequest> m_requests;

    QTimer m_lazyLoadTimer;
};

#endif // MARKERLOADER
