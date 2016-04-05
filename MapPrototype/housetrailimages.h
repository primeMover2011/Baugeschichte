#ifndef HOUSETRAILIMAGES_H
#define HOUSETRAILIMAGES_H

#include <QObject>
#include <QAbstractListModel>
#include <QStringList>
#include <QGeoCoordinate>

class HouseTrail: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int dbId READ dbId WRITE setDbId NOTIFY dbIdChanged)
    Q_PROPERTY(QString houseTitle READ houseTitle WRITE setHouseTitle NOTIFY houseTitleChanged)
    Q_PROPERTY(QGeoCoordinate theLocation READ theLocation WRITE setTheLocation NOTIFY theLocationChanged)
    Q_PROPERTY(QString categories READ categories WRITE setCategories NOTIFY categoriesChanged)
    Q_PROPERTY(QString geoHash READ geoHash WRITE setGeoHash NOTIFY geoHashChanged)

public:
    explicit HouseTrail(QObject *parent = 0);

    int dbId() const
    {
        return m_dbId;
    }
    QString houseTitle() const
    {
        return m_houseTitle;
    }

    QGeoCoordinate theLocation() const
    {
        return m_theLocation;
    }

    QString categories() const
    {
        return m_categories;
    }

    QString geoHash() const
    {
        return m_geoHash;
    }

public slots:
    void setDbId(int dbId);
    void setHouseTitle(QString houseTitle);
    void setTheLocation(QGeoCoordinate theLocation);
    void setCategories(QString categories);
    void setGeoHash(QString geoHash);

signals:
    void dbIdChanged(int dbId);
    void houseTitleChanged(QString houseTitle);
    void theLocationChanged(QGeoCoordinate theLocation);
    void categoriesChanged(QString categories);
    void geoHashChanged(QString geoHash);

protected:
    int m_dbId;
    QString m_houseTitle;
    QGeoCoordinate m_theLocation;
    QString m_categories;
    QString m_geoHash;
};

class HousetrailModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum HousetrailRoles {
        DbIdRole = Qt::UserRole + 1,
        HouseTitleRole,
        CoordinateRole,
        CategoryRole,
        GeohashRole,

    };

    HousetrailModel(QObject *parent = 0);
    void append(HouseTrail* aHouseTrail);
    Q_INVOKABLE void clear();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QString getHash(double lat, double lon);

    Q_INVOKABLE bool contains(double lat, double lon);

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

protected:
    QHash<int, QByteArray> roleNames() const;
private:
    QList<HouseTrail*> m_Housetrails;
    QHash<QString, HouseTrail*> m_Contained;
};


/*
class HousetrailImages
{
public:
    HousetrailImages(const QString& id, const QString& aName, const QString& aUrl, const QString& aYear, const QString& aDescription):
        m_Identifier(id), m_Name(aName), m_Url(aUrl),m_Year(aYear),m_Description(aDescription) {}
//    ~HousetrailImages();
    //ID, Name, Url, Jahr, beschreibung
    QString Identifier() const
        {return m_Identifier;}

    QString Name() const
            {return m_Name;}
    QString Url() const
    {return m_Url;}

    QString Year() const
    {return m_Year;}

    QString Description() const
    {return m_Description;}


private:
    QString m_Identifier;
    QString m_Name;
    QString m_Url;
    QString m_Year;
    QString m_Description;
};




class HousetrailImagesModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum HousetrailImagesRoles {
        IdentifierRole = Qt::UserRole + 1,
        NameRole,
        UrlRole,
        YearRole,
        DescriptionRole
    };
    HousetrailImagesModel(QObject *parent = 0);
    void addHousetrail(const HousetrailImages& aHouseTrail);
    void clear();
    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

protected:
    QHash<int, QByteArray> roleNames() const;
private:
    QList<HousetrailImages> m_HousetrailImages;
};
*/
#endif // HOUSETRAILIMAGES_H
