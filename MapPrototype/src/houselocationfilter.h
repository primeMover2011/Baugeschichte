#ifndef HOUSELOCATIONFILTER_H
#define HOUSELOCATIONFILTER_H

#include <QGeoCoordinate>
#include <QList>
#include <QSortFilterProxyModel>
#include <QStringList>
#include <QVariant>

/**
 * @brief The HouseLocationFilter filters the HouseTrailModel by location and radius
 */
class HouseLocationFilter : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QGeoCoordinate location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(double radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(double minDistance READ minDistance WRITE setMinDistance NOTIFY minDistanceChanged)
    Q_PROPERTY(QString unfilteredHouseTitle READ unfilteredHouseTitle WRITE setUnfilteredHouseTitle NOTIFY unfilteredHouseTitleChanged)

public:
    HouseLocationFilter(QObject* parent = nullptr);

    const QGeoCoordinate& location() const;
    double radius() const;
    double minDistance() const;

    void setUnfilteredHouseTitle(const QString& houseTitle);
    QString unfilteredHouseTitle() const;

    Q_INVOKABLE void setRouteHouses(QVariant variant);

public slots:
    /**
     * @param radius in meters
     */
    void setLocation(const QGeoCoordinate& location);
    void setRadius(double radius);
    /**
     * Sets the minimal distance between markers in meters
     */
    void setMinDistance(double minDistance);


signals:
    void radiusChanged(double radius);
    void locationChanged(const QGeoCoordinate& location);
    void minDistanceChanged(double minDistance);
    void unfilteredHouseTitleChanged(QString unfilteredHouseTitle);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private:
    bool isCloseToOtherPosition(const QGeoCoordinate& coord) const;

    QGeoCoordinate m_location;
    double m_radius;
    double m_minDistance;

    mutable QList<QGeoCoordinate> m_usedCoordinates;

    QString m_unfilteredHouseTitle;
    QStringList m_routeHouses;
};

#endif // HOUSELOCATIONFILTER_H
