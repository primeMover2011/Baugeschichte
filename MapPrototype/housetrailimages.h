#ifndef HOUSETRAILIMAGES_H
#define HOUSETRAILIMAGES_H

#include <QObject>
#include <QAbstractListModel>
#include <QStringList>
#include <QGeoCoordinate>

class HouseTrail
{
public:
    explicit HouseTrail();

    qint64 dbId() const
    {
        return m_dbId;
    }
    const QString& houseTitle() const
    {
        return m_houseTitle;
    }

    const QGeoCoordinate& theLocation() const
    {
        return m_theLocation;
    }

    const QString& categories() const
    {
        return m_categories;
    }

    const QString& geoHash() const
    {
        return m_geoHash;
    }

    void setDbId(qint64 dbId);
    void setHouseTitle(const QString& houseTitle);
    void setTheLocation(const QGeoCoordinate& theLocation);
    void setCategories(const QString& categories);
    void setGeoHash(const QString& geoHash);

protected:
    qint64 m_dbId;
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
    Q_SLOT void append(const QVector<HouseTrail>& aHouseTrail);
    Q_INVOKABLE void clear();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QString getHash(double lat, double lon);

    bool contains(qint64 id);

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

protected:
    QHash<int, QByteArray> roleNames() const;
private:
    QList<HouseTrail*> m_Housetrails;
    QHash<qint64, HouseTrail*> m_Contained;
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
