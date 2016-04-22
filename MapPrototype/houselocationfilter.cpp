#include "houselocationfilter.h"
#include "housetrailimages.h"

#include <QDebug>

HouseLocationFilter::HouseLocationFilter(QObject* parent)
    : QSortFilterProxyModel(parent)
    , m_radius(200.0)
    , m_location()
{
    setDynamicSortFilter(true);
}

double HouseLocationFilter::radius() const
{
    return m_radius;
}

const QGeoCoordinate& HouseLocationFilter::location() const
{
    return m_location;
}

void HouseLocationFilter::setRadius(double radius)
{
    if (std::fabs(m_radius - radius) < 1e-9)
        return;

    m_radius = radius;
    emit radiusChanged(radius);
    invalidateFilter();
}

void HouseLocationFilter::setLocation(const QGeoCoordinate& location)
{
    if (location == m_location) {
        return;
    }

    m_location = location;
    emit locationChanged(m_location);
    invalidateFilter();
}

bool HouseLocationFilter::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
{
    QVariant variant = sourceModel()->data(sourceModel()->index(source_row, 0, source_parent), HousetrailModel::CoordinateRole);

    if (!variant.canConvert<QGeoCoordinate>()) {
        return false;
    }

    QGeoCoordinate coord = variant.value<QGeoCoordinate>();
    return coord.distanceTo(m_location) <= m_radius;
}
