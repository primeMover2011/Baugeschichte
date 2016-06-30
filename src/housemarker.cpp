#include "housemarker.h"

HouseMarker::HouseMarker()
    : m_dbId(-1)
{
}

void HouseMarker::setDbId(qint64 dbId)
{
    m_dbId = dbId;
}

void HouseMarker::setHouseTitle(const QString& houseTitle)
{
    m_houseTitle = houseTitle;
}

void HouseMarker::setLocation(const QGeoCoordinate& theLocation)
{
    if (m_location == theLocation) {
        return;
    }

    m_location = theLocation;
}

void HouseMarker::setCategories(const QString& categories)
{
    m_categories = categories;
}
