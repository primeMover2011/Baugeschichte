#ifndef HOUSEMARKER_H
#define HOUSEMARKER_H

#include <QGeoCoordinate>
#include <QString>

/**
 * @brief The HouseMarker class contains the data for a marker on the map
 */
class HouseMarker
{
public:
    explicit HouseMarker();

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
        return m_location;
    }

    const QString& categories() const
    {
        return m_categories;
    }

    void setDbId(qint64 dbId);
    void setHouseTitle(const QString& houseTitle);
    void setTheLocation(const QGeoCoordinate& theLocation);
    void setCategories(const QString& categories);

protected:
    qint64 m_dbId;
    QString m_houseTitle;
    QGeoCoordinate m_location;
    QString m_categories;
};

inline bool operator<(const HouseMarker& lhs, const HouseMarker& rhs)
{
    return lhs.dbId() < rhs.dbId();
}

#endif // HOUSEMARKER_H
