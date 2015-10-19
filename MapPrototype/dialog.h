#ifndef DIALOG
#define DIALOG
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
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


public:
    explicit Dialog(HousetrailModel* aHouseTrails, QObject *parent = 0);

    void setInfotext(QString aText);

    QString infotext() const
         { return m_infotext; }
    double latitude() const
        { return m_latitude;}
    QString detailTitle() const
    {
            return m_detailTitle;
    }
    void setDetailTitle(const QString aDetailTitle)
    {
            m_detailTitle=aDetailTitle;
            emit detailTitleChanged(m_detailTitle);
    }
    double longitude() const
        { return m_longitude;}

    Q_INVOKABLE void getAllPois();

    Q_INVOKABLE void locateMe() const
    {
        if (m_source)
        {
            m_source->startUpdates();
        }

    }
    int poiID() const
    {return m_poiID;}
    void setPoiID(const int apoiID)
    {
        m_poiID = apoiID;
        emit poiIDChanged(m_poiID);
    }


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
    void newHousetrail(HouseTrail* aNewHouseTrail);

public slots:
    /*!
        This slot is invoked from the HTML client side and the text displayed on the server side.
    */

    void onNewHouseTrail(HouseTrail* aNewHouseTrail)
    {
        HouseTrail* aHouseTrail = new HouseTrail(m_HouseTrailImages);
        aHouseTrail->setDbId(aNewHouseTrail->dbId());
        aHouseTrail->setHouseTitle(aNewHouseTrail->houseTitle());
        aHouseTrail->setTheLocation(aNewHouseTrail->theLocation());
        m_HouseTrailImages->append(aNewHouseTrail);

    }
    void slotError(QNetworkReply::NetworkError anError)
    {
        qDebug() << "Networkerror";
    }

    void httpFinished()
    {
        qDebug() << "Http finished ";
    }
//
    void replyFinished(QNetworkReply* theReply)
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

//                  QJson::Parser parser;
//                  bool ok;

                  qDebug()<<"code: "<<
                            theReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString() <<
                            " response: "<< theResponse;
                  theReply->deleteLater();

      }

    }


    void poiSelected(const int aPoiId)
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

    void poisFinished(QNetworkReply* theReply);
    void createModelAsync(QNetworkReply *theReply);
private slots:
    void httpReadyRead(QNetworkReply *reply){
        qDebug() << "Http ready read ";
    }

    void positionUpdated(const QGeoPositionInfo &info)
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
//          emit locationChanged(m_latitude, m_longitude);

    }
private:
    QString m_infotext;
    QString m_detailTitle;
    QGeoPositionInfoSource* m_source;
    double m_latitude;
    double m_longitude;
    int m_poiID;
    QNetworkAccessManager* m_manager;
    HousetrailModel* m_HouseTrailImages;


};


#endif // DIALOG

