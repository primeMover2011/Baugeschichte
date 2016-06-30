#include "housetrailimages.h"

#include <QDebug>

#include <algorithm>
#include <set>

HousetrailModel::HousetrailModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_maxSize(10000)
{
}

HousetrailModel::~HousetrailModel()
{
    clear();
}

void HousetrailModel::append(const QVector<HouseMarker>& aHouseTrail)
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
        m_Contained.insert(house.dbId(), newHouse);
        m_Housetrails.append(newHouse);
    }
    endInsertRows();
}

void HousetrailModel::clear()
{
    beginRemoveRows(QModelIndex(), 0, m_Housetrails.count());
    qDeleteAll(m_Housetrails);
    m_Housetrails.clear();
    m_Contained.clear();
    endRemoveRows();
}

int HousetrailModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_Housetrails.count();
}

bool HousetrailModel::contains(qint64 id) const
{
    return m_Contained.contains(id);
}

QVariant HousetrailModel::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_Housetrails.count())
        return QVariant();

    HouseMarker* aHousetrail = m_Housetrails[index.row()];
    if (role == DbIdRole)
        return aHousetrail->dbId();
    else if (role == HouseTitleRole)
        return aHousetrail->houseTitle();
    else if (role == CoordinateRole)
        return QVariant::fromValue(aHousetrail->theLocation());
    else if (role == CategoryRole)
        return aHousetrail->categories();
    return QVariant();
}

const HouseMarker* HousetrailModel::get(int idx) const
{
    return m_Housetrails.at(idx);
}

QString HousetrailModel::getHouseTitleById(qint64 id) const
{
    if (!contains(id)) {
        return QString();
    }

    HouseMarker* house = m_Contained.value(id);
    return house->houseTitle();
}

HouseMarker* HousetrailModel::getHouseByTitle(const QString& title) const
{
    for (auto house : m_Housetrails) {
        if (house->houseTitle() == title) {
            return house;
        }
    }
    return nullptr;
}

QHash<int, QByteArray> HousetrailModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DbIdRole] = "dbId";
    roles[HouseTitleRole] = "title";
    roles[CoordinateRole] = "coord";
    roles[CategoryRole] = "category";
    return roles;
}

void HousetrailModel::limitSize()
{
    int size = m_Housetrails.size();
    if (size > m_maxSize) {
        beginRemoveRows(QModelIndex(), 0, size - m_maxSize - 1);
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
