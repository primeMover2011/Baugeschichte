#ifndef DIALOG
#define DIALOG

#include <QObject>
#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>
#include <QList>
#include <QNetworkReply>
#include <QVector>
#include "housetrailimages.h"

class Dialog : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString infotext READ infotext WRITE setInfotext NOTIFY infotextChanged)
    Q_PROPERTY(double latitude READ latitude /*WRITE setLatitude*/ NOTIFY latitudeChanged)
    Q_PROPERTY(double longitude READ longitude /*WRITE setLongitude*/ NOTIFY longitudeChanged)
    Q_PROPERTY(int poiID READ poiID WRITE setPoiID NOTIFY poiIDChanged)
    Q_PROPERTY(QString detailTitle READ detailTitle WRITE setDetailTitle NOTIFY detailTitleChanged)
//    Q_PROPERTY(HousetrailImagesModel houseTrailImages READ houseTrailImages NOTIFY houseTrailImagesChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit Dialog(HousetrailModel* aHouseTrails, QObject *parent = 0);

    void setInfotext(QString aText);
    QString infotext() const;
    void setPoiID(const int apoiID);
    int poiID() const;
    double latitude() const;
    double longitude() const;
    void setDetailTitle(const QString aDetailTitle);
    QString detailTitle() const;

    bool loading() const;

    Q_INVOKABLE void getAllPois();
    Q_INVOKABLE void getPois(double lat, double lon, double radius, double zoomlevel);
    Q_INVOKABLE QString getGeoHashFromLocation(QGeoCoordinate theLocation, int thePrecision);
    Q_INVOKABLE QGeoCoordinate getLocationFromGeoHash(QString theGeoHash);
    Q_INVOKABLE void locateMe() const;

signals:
    /*!
        This signal is emitted from the C++ side and the text displayed on the HTML client side.
    */
    void sendText(const QString &text);
    void infotextChanged(QString);
    void latitudeChanged(double);
    void longitudeChanged(double);
    void locationChanged(double, double);
    void poiIDChanged(int);
    void detailTitleChanged(const QString& aDetailTitle);
    void newHousetrail(QVector<HouseTrail> aNewHouseTrail);
    void loadingChanged(bool loading);

public slots:
    void slotError(QNetworkReply::NetworkError anError);
    void httpFinished();
    void replyFinished(QNetworkReply* theReply);
    void poiSelected(const int aPoiId);
    void poisFinished(QNetworkReply* theReply);
    void createModelAsync(QNetworkReply *theReply);

private slots:
    void httpReadyRead(QNetworkReply *reply);
    void positionUpdated(const QGeoPositionInfo &info);

private:
    void setLoading(bool loading);

    QString m_infotext;
    QString m_detailTitle;
    QGeoPositionInfoSource* m_source;
    double m_latitude;
    double m_longitude;
    int m_poiID;
    QNetworkAccessManager* m_manager;
    HousetrailModel* m_HouseTrailImages;
    bool m_loading;

    QList<QNetworkRequest> m_requests;
};

#endif // DIALOG
