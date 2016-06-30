#include "housemarkermodel.h"

#include <QDebug>

#include <algorithm>
#include <set>

HouseMarkerModel::HouseMarkerModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_maxSize(10000)
{
}

HouseMarkerModel::~HouseMarkerModel()
{
    clear();
}

void HouseMarkerModel::append(const QVector<HouseMarker>& aHouseTrail)
{
    limitSize();

    std::set<HouseMarker> newHouses; // use a set to eliminate duplicates
    foreach (const HouseMarker& house, aHouseTrail) {
        if (!this->contains(house.dbId())) {
            newHouses.insert(house);
        }
    }

    int insertEnd = rowCount() + static_cast<int>(newHouses.size()) - 1;
    beginInsertRows(QModelIndex(), rowCount(), insertEnd);
    foreach (const HouseMarker& house, newHouses) {
        HouseMarker* newHouse = new HouseMarker(house);
        m_contained.insert(house.dbId(), newHouse);
        m_housetrails.append(newHouse);
    }
    endInsertRows();
}

void HouseMarkerModel::clear()
{
    beginRemoveRows(QModelIndex(), 0, m_housetrails.count());
    qDeleteAll(m_housetrails);
    m_housetrails.clear();
    m_contained.clear();
    endRemoveRows();
}

int HouseMarkerModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_housetrails.count();
}

bool HouseMarkerModel::contains(qint64 id) const
{
    return m_contained.contains(id);
}

QVariant HouseMarkerModel::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_housetrails.count())
        return QVariant();

    HouseMarker* aHousetrail = m_housetrails[index.row()];
    if (role == DbIdRole)
        return aHousetrail->dbId();
    else if (role == HouseTitleRole)
        return aHousetrail->houseTitle();
    else if (role == CoordinateRole)
        return QVariant::fromValue(aHousetrail->location());
    else if (role == CategoryRole)
        return aHousetrail->categories();
    return QVariant();
}

const HouseMarker* HouseMarkerModel::get(int idx) const
{
    return m_housetrails.at(idx);
}

QString HouseMarkerModel::getHouseTitleById(qint64 id) const
{
    if (!contains(id)) {
        return QString();
    }

    HouseMarker* house = m_contained.value(id);
    return house->houseTitle();
}

HouseMarker* HouseMarkerModel::getHouseByTitle(const QString& title) const
{
    for (auto house : m_housetrails) {
        if (house->houseTitle() == title) {
            return house;
        }
    }
    return nullptr;
}

QHash<int, QByteArray> HouseMarkerModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DbIdRole] = "dbId";
    roles[HouseTitleRole] = "title";
    roles[CoordinateRole] = "coord";
    roles[CategoryRole] = "category";
    return roles;
}

void HouseMarkerModel::limitSize()
{
    int size = m_housetrails.size();
    if (size > m_maxSize) {
        beginRemoveRows(QModelIndex(), 0, size - m_maxSize - 1);
        while (m_housetrails.size() > m_maxSize) {
            int i = m_contained.remove(m_housetrails[0]->dbId());
            if (i != 1) {
                qWarning() << "m_Contained.remove returned" << i << "but should be 1";
            }
            delete m_housetrails[0];
            m_housetrails.removeFirst();
        }
        endRemoveRows();
    }
}
