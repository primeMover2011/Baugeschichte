#include "housetrailimages.h"

#include <Geohash.hpp>

#include <QDebug>

#include <set>

HouseTrail::HouseTrail()
    : m_dbId(-1)
{
}

void HouseTrail::setDbId(qint64 dbId)
{
    m_dbId = dbId;
}

void HouseTrail::setHouseTitle(const QString& houseTitle)
{
    m_houseTitle = houseTitle;
}

void HouseTrail::setTheLocation(const QGeoCoordinate& theLocation)
{
    if (m_theLocation == theLocation)
        return;

    m_theLocation = theLocation;
    std::string aGeoHash;
    GeographicLib::Geohash::Forward(m_theLocation.latitude(),m_theLocation.longitude(),12,aGeoHash);
    setGeoHash(QString::fromStdString(aGeoHash));
}

void HouseTrail::setCategories(const QString& categories)
{
    m_categories = categories;
}

void HouseTrail::setGeoHash(const QString& geoHash)
{
    m_geoHash = geoHash;
}


HousetrailModel::HousetrailModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_maxSize(1000)
{
}

HousetrailModel::~HousetrailModel()
{
    clear();
}

void HousetrailModel::append(const QVector<HouseTrail>& aHouseTrail)
{
    std::set<HouseTrail> newHouses; // use a set to eliminate duplicates
    foreach (const HouseTrail& house, aHouseTrail) {
        if (!this->contains(house.dbId())) {
            newHouses.insert(house);
        }
    }

    limitSize();

    int insertEnd = rowCount() + static_cast<int>(newHouses.size()) - 1;
    beginInsertRows(QModelIndex(), rowCount(), insertEnd);
    foreach (const HouseTrail& house, newHouses) {
        HouseTrail* newHouse = new HouseTrail(house);
        m_Contained.insert(house.dbId(), newHouse);
        m_Housetrails.append(newHouse);
    }
    endInsertRows();
}

void HousetrailModel::clear()
{
    beginRemoveRows(QModelIndex(),0,m_Housetrails.count());
    qDeleteAll(m_Housetrails);
    m_Housetrails.clear();
    m_Contained.clear();
    endRemoveRows();
}

int HousetrailModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_Housetrails.count();
}

bool HousetrailModel::contains(qint64 id) {
    return m_Contained.contains(id);
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

void HousetrailModel::limitSize()
{
    int size = m_Housetrails.size();
    if (size > m_maxSize) {
        beginRemoveRows(QModelIndex(), 0, size-m_maxSize-1);
        while (m_Housetrails.size() > m_maxSize) {
            int i = m_Contained.remove(m_Housetrails[0]->dbId());
            if (i != 1) {
                qWarning() << "m_Contained.remove returned" << i << "but should be 1";
            }
            delete m_Housetrails[0];
            m_Housetrails.removeFirst();
        }
        endRemoveRows();
    }
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
