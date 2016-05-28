#include "houselocationfilter.h"
#include "housetrailimages.h"

#include <QDebug>

HouseLocationFilter::HouseLocationFilter(QObject* parent)
    : QSortFilterProxyModel(parent)
    , m_location()
    , m_radius(200.0)
    , m_minDistance(100.0)
{
    setDynamicSortFilter(true);
}

const QGeoCoordinate& HouseLocationFilter::location() const
{
    return m_location;
}

double HouseLocationFilter::radius() const
{
    return m_radius;
}

double HouseLocationFilter::minDistance() const
{
    return m_minDistance;
}

void HouseLocationFilter::setLocation(const QGeoCoordinate& location)
{
    if (location == m_location) {
        return;
    }

    m_location = location;
    emit locationChanged(m_location);
    m_usedCoordinates.clear();
    invalidateFilter();
}

void HouseLocationFilter::setRadius(double radius)
{
    if (std::fabs(m_radius - radius) < 1e-9)
        return;

    m_radius = radius;
    emit radiusChanged(radius);
    m_usedCoordinates.clear();
    invalidateFilter();
}

void HouseLocationFilter::setMinDistance(double minDistance)
{
    if (std::fabs(minDistance - m_minDistance) < 1e-9) {
        return;
    }

    m_minDistance = minDistance;
    emit minDistanceChanged(minDistance);
    m_usedCoordinates.clear();
    invalidateFilter();
}

bool HouseLocationFilter::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
{
    QVariant variant = sourceModel()->data(sourceModel()->index(source_row, 0, source_parent), HousetrailModel::CoordinateRole);

    if (!variant.canConvert<QGeoCoordinate>()) {
        return false;
    }

    QGeoCoordinate coord = variant.value<QGeoCoordinate>();
    if (coord.distanceTo(m_location) > m_radius) {
        return false;
    }

    if (isCloseToOtherPosition(coord)) {
        return false;
    }

    m_usedCoordinates.append(coord);

    return true;
}

bool HouseLocationFilter::isCloseToOtherPosition(const QGeoCoordinate& coord) const
{
    Q_FOREACH(const QGeoCoordinate& usedCoord, m_usedCoordinates) {
        if (coord.distanceTo(usedCoord) < m_minDistance) {
            return true;
        }
    }

    return false;
}
