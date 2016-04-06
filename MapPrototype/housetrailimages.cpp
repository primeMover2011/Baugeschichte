#include "housetrailimages.h"

#include <Geohash.hpp>

HouseTrail::HouseTrail(QObject *parent)
    : QObject(parent)
{
}

void HouseTrail::setDbId(int dbId)
{
    if (m_dbId == dbId)
        return;

    m_dbId = dbId;
    emit dbIdChanged(dbId);
}

void HouseTrail::setHouseTitle(QString houseTitle)
{
    if (m_houseTitle == houseTitle)
        return;

    m_houseTitle = houseTitle;
    emit houseTitleChanged(houseTitle);
}

void HouseTrail::setTheLocation(QGeoCoordinate theLocation)
{
    if (m_theLocation == theLocation)
        return;

    m_theLocation = theLocation;
    std::string aGeoHash;
    GeographicLib::Geohash::Forward(m_theLocation.latitude(),m_theLocation.longitude(),12,aGeoHash);
    setGeoHash(QString::fromStdString(aGeoHash));

    emit theLocationChanged(theLocation);
}

void HouseTrail::setCategories(QString categories)
{
    if (m_categories == categories)
        return;

    m_categories = categories;
    emit categoriesChanged(categories);
}

void HouseTrail::setGeoHash(QString geoHash)
{
    if (m_geoHash == geoHash)
        return;

    m_geoHash = geoHash;
    emit geoHashChanged(geoHash);
}

HousetrailModel::HousetrailModel(QObject *parent){
    Q_UNUSED(parent)
}

void HousetrailModel::append(HouseTrail *aHouseTrail)
{
    auto lat = aHouseTrail->theLocation().latitude();
    auto lon = aHouseTrail->theLocation().longitude();
    if (this->contains(lat,lon)) return;
    QString theHash= getHash(lat,lon);
    m_Contained[theHash]=aHouseTrail;
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_Housetrails.append(aHouseTrail);
    endInsertRows();
}

void HousetrailModel::clear()
{
    beginRemoveRows(QModelIndex(),0,m_Housetrails.count());
    m_Housetrails.clear();
    endRemoveRows();
}

int HousetrailModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_Housetrails.count();
}

QString HousetrailModel::getHash(double lat, double lon)
{
    return QString("%1o%2").arg(lat,0,'f',7).arg(lon,0,'f',7);
}

bool HousetrailModel::contains(double lat, double lon) {
    QString theHash= getHash(lat,lon);
    return m_Contained.contains(theHash);
}

QVariant HousetrailModel::data(const QModelIndex &index, int role) const
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
    else if (role == GeohashRole)
        return aHousetrail->geoHash();
    return QVariant();
}

QHash<int, QByteArray> HousetrailModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DbIdRole] = "dbId";
    roles[HouseTitleRole] = "title";
    roles[CoordinateRole] = "coord";
    roles[CategoryRole] = "category";
    roles[GeohashRole] = "geohash";
    return roles;
}

/*
HousetrailImagesModel::HousetrailImagesModel(QObject *parent) : QAbstractListModel(parent)
{

}

void HousetrailImagesModel::addHousetrail(const HousetrailImages &aHouseTrail)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_HousetrailImages << aHouseTrail;
    endInsertRows();

}

void HousetrailImagesModel::clear()
{
    beginRemoveRows(QModelIndex(),0,m_HousetrailImages.count());
    m_HousetrailImages.clear();
    endRemoveRows();
}

int HousetrailImagesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_HousetrailImages.count();
}

QVariant HousetrailImagesModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_HousetrailImages.count())
        return QVariant();

    const HousetrailImages& aHousetrail = m_HousetrailImages[index.row()];
    if (role == IdentifierRole)
        return aHousetrail.Identifier();
    else if (role == NameRole)
        return aHousetrail.Name();
    else if (role == DescriptionRole)
        return aHousetrail.Description();
    else if (role == UrlRole)
        return aHousetrail.Url();
    else if (role == YearRole)
        return aHousetrail.Year();
    return QVariant();
}

QHash<int, QByteArray> HousetrailImagesModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdentifierRole] = "identifier";
    roles[NameRole] = "name";
    roles[DescriptionRole] = "description";
    roles[UrlRole] = "imageurl";
    roles[YearRole] = "year";

    return roles;
}
*/
