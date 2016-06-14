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

inline bool operator< (const HouseTrail& lhs, const HouseTrail& rhs)
{
    return  lhs.dbId() < rhs.dbId();
}

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
    ~HousetrailModel();

    Q_SLOT void append(const QVector<HouseTrail>& aHouseTrail);
    Q_INVOKABLE void clear();

    int rowCount(const QModelIndex& parent = QModelIndex()) const;

    bool contains(qint64 id);

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    const HouseTrail* get(int idx) const;

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    /**
     * Removes the first (oldes) entries, so that only m_maxSize items are left in the container
     */
    void limitSize();

    QList<HouseTrail*> m_Housetrails;
    QHash<qint64, HouseTrail*> m_Contained;

    int m_maxSize;
};

#endif // HOUSETRAILIMAGES_H
