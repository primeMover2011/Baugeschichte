#include "housetrailimages.h"


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
