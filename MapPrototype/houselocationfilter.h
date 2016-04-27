#ifndef HOUSELOCATIONFILTER_H
#define HOUSELOCATIONFILTER_H

#include <QGeoCoordinate>
#include <QList>
#include <QSortFilterProxyModel>

/**
 * @brief The HouseLocationFilter filters the HouseTrailModel by location and radius
 */
class HouseLocationFilter : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QGeoCoordinate location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(double radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(double minDistanceFactor READ minDistanceFactor WRITE setMinDistanceFactor NOTIFY minDistanceFactorChanged)

public:
    HouseLocationFilter(QObject* parent = nullptr);

    const QGeoCoordinate& location() const;
    double radius() const;
    double minDistanceFactor() const;

public slots:
    /**
     * @param radius in meters
     */
    void setLocation(const QGeoCoordinate& location);
    void setRadius(double radius);
    /**
     * Sets the minimal distance between markers.
     * The distance is this factor * radius
     */
    void setMinDistanceFactor(double minDistanceFactor);


signals:
    void radiusChanged(double radius);
    void locationChanged(const QGeoCoordinate& location);
    void minDistanceFactorChanged(double minDistanceFactor);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private:
    bool isCloseToOtherPosition(const QGeoCoordinate& coord) const;

    QGeoCoordinate m_location;
    double m_radius;
    double m_minDistanceFactor;

    mutable QList<QGeoCoordinate> m_usedCoordinates;
};

#endif // HOUSELOCATIONFILTER_H
