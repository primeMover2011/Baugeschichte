#ifndef HOUSETRAILIMAGES_H
#define HOUSETRAILIMAGES_H

#include <QObject>
#include <QAbstractListModel>
#include <QStringList>
#include <QGeoCoordinate>
#include <Geohash.hpp>

class HouseTrail: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int dbId READ dbId WRITE setDbId NOTIFY dbIdChanged)
    Q_PROPERTY(QString houseTitle READ houseTitle WRITE setHouseTitle NOTIFY houseTitleChanged)
    Q_PROPERTY(QGeoCoordinate theLocation READ theLocation WRITE setTheLocation NOTIFY theLocationChanged)
    Q_PROPERTY(QString categories READ categories WRITE setCategories NOTIFY categoriesChanged)
    Q_PROPERTY(QString geoHash READ geoHash WRITE setGeoHash NOTIFY geoHashChanged)

protected:
    int m_dbId;
    QString m_houseTitle;
    QGeoCoordinate m_theLocation;
    QString m_categories;
    QString m_geoHash;

public:

    explicit HouseTrail(QObject *parent = 0): QObject(parent) {}

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
void setDbId(int dbId)
{
    if (m_dbId == dbId)
        return;

    m_dbId = dbId;
    emit dbIdChanged(dbId);
}
void setHouseTitle(QString houseTitle)
{
    if (m_houseTitle == houseTitle)
        return;

    m_houseTitle = houseTitle;
    emit houseTitleChanged(houseTitle);
}

void setTheLocation(QGeoCoordinate theLocation)
{
    if (m_theLocation == theLocation)
        return;

    m_theLocation = theLocation;
    std::string aGeoHash;
    GeographicLib::Geohash::Forward(m_theLocation.latitude(),m_theLocation.longitude(),18,aGeoHash);
    setGeoHash(QString::fromStdString(aGeoHash));

    emit theLocationChanged(theLocation);
}

void setCategories(QString categories)
{
    if (m_categories == categories)
        return;

    m_categories = categories;
    emit categoriesChanged(categories);
}

void setGeoHash(QString geoHash)
{
    if (m_geoHash == geoHash)
        return;

    m_geoHash = geoHash;
    emit geoHashChanged(geoHash);
}

signals:
void dbIdChanged(int dbId);
void houseTitleChanged(QString houseTitle);
void theLocationChanged(QGeoCoordinate theLocation);
void categoriesChanged(QString categories);
void geoHashChanged(QString geoHash);
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
    };
    HousetrailModel(QObject *parent = 0){
        Q_UNUSED(parent)

    }
    void append(HouseTrail* aHouseTrail)
    {
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_Housetrails.append(aHouseTrail);
        endInsertRows();
    }
    void clear()
    {
        beginRemoveRows(QModelIndex(),0,m_Housetrails.count());
        m_Housetrails.clear();
        endRemoveRows();
    }

    int rowCount(const QModelIndex & parent = QModelIndex()) const
    {
        Q_UNUSED(parent);
        return m_Housetrails.count();
    }

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const
    {
        if (index.row() < 0 || index.row() >= m_Housetrails.count())
            return QVariant();

        HouseTrail* aHousetrail = m_Housetrails[index.row()];
        if (role == DbIdRole)
            return aHousetrail->dbId();
        else if (role == HouseTitleRole)
            return aHousetrail->houseTitle();
        else if (role == CoordinateRole)
            return QVariant::fromValue(aHousetrail->theLocation());
        else if (role == CategoryRole)
            return aHousetrail->categories();
        return QVariant();
    }

protected:
    QHash<int, QByteArray> roleNames() const
    {
        QHash<int, QByteArray> roles;
        roles[DbIdRole] = "dbId";
        roles[HouseTitleRole] = "title";
        roles[CoordinateRole] = "coord";
        roles[CategoryRole] = "category";
        return roles;
    }
private: QList<HouseTrail*> m_Housetrails;
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
