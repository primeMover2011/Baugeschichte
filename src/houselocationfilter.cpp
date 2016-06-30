/**
 ** This file is part of the Baugeschichte.at project.
 **
 ** The MIT License (MIT)
 **
 ** Copyright (c) 2016 Guenter Schwann
 **
 ** Permission is hereby granted, free of charge, to any person obtaining a copy
 ** of this software and associated documentation files (the "Software"), to deal
 ** in the Software without restriction, including without limitation the rights
 ** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ** copies of the Software, and to permit persons to whom the Software is
 ** furnished to do so, subject to the following conditions:
 **
 ** The above copyright notice and this permission notice shall be included in all
 ** copies or substantial portions of the Software.
 **
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 ** SOFTWARE.
 **/

#include "houselocationfilter.h"
#include "housemarkermodel.h"

#include <QDebug>
#include <QJSValue>
#include <QJsonObject>

#include <cmath>

HouseLocationFilter::HouseLocationFilter(QObject* parent)
    : QSortFilterProxyModel(parent)
    , m_location()
    , m_radius(200.0)
    , m_minDistance(100.0)
    , m_unfilteredHouseTitle("")
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

QString HouseLocationFilter::unfilteredHouseTitle() const
{
    return m_unfilteredHouseTitle;
}

void HouseLocationFilter::setRouteHouses(QVariant variant)
{
    m_routeHouses.clear();

    QVariantList list = variant.value<QVariantList>();
    if (list.isEmpty()) {
        return;
    }
    for (const QVariant& houseVar : list) {
        m_routeHouses << houseVar.toString();
    }

    m_usedCoordinates.clear();
    invalidateFilter();
}

void HouseLocationFilter::setUnfilteredHouseTitle(const QString& houseTitle)
{
    if (houseTitle == m_unfilteredHouseTitle) {
        return;
    }

    m_unfilteredHouseTitle = houseTitle;
    emit unfilteredHouseTitleChanged(m_unfilteredHouseTitle);
    m_usedCoordinates.clear();
    invalidateFilter();
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
    if (std::abs(m_radius - radius) < 1e-9)
        return;

    m_radius = radius;
    emit radiusChanged(radius);
    m_usedCoordinates.clear();
    invalidateFilter();
}

void HouseLocationFilter::setMinDistance(double minDistance)
{
    if (std::abs(minDistance - m_minDistance) < 1e-9) {
        return;
    }

    m_minDistance = minDistance;
    emit minDistanceChanged(minDistance);
    m_usedCoordinates.clear();
    invalidateFilter();
}

bool HouseLocationFilter::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
{
    QVariant variant
        = sourceModel()->data(sourceModel()->index(source_row, 0, source_parent), HouseMarkerModel::CoordinateRole);
    if (!variant.canConvert<QGeoCoordinate>()) {
        return false;
    }

    QGeoCoordinate coord = variant.value<QGeoCoordinate>();
    if (coord.distanceTo(m_location) > m_radius) {
        return false;
    }

    QVariant titleVariant
        = sourceModel()->data(sourceModel()->index(source_row, 0, source_parent), HouseMarkerModel::HouseTitleRole);
    if (titleVariant.canConvert<QString>()) {
        QString title = titleVariant.value<QString>();
        if (title == m_unfilteredHouseTitle || m_routeHouses.contains(title)) {
            m_usedCoordinates.append(coord);
            return true;
        }
    }

    if (isCloseToOtherPosition(coord)) {
        return false;
    }

    m_usedCoordinates.append(coord);

    return true;
}

bool HouseLocationFilter::isCloseToOtherPosition(const QGeoCoordinate& coord) const
{
    Q_FOREACH (const QGeoCoordinate& usedCoord, m_usedCoordinates) {
        if (coord.distanceTo(usedCoord) < m_minDistance) {
            return true;
        }
    }

    return false;
}
