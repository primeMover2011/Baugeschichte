#ifndef HOUSETRAILIMAGES_H
#define HOUSETRAILIMAGES_H

#include "housemarker.h"

#include <QAbstractListModel>

class HousetrailModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum HousetrailRoles {
        DbIdRole = Qt::UserRole + 1,
        HouseTitleRole,
        CoordinateRole,
        CategoryRole,
    };

    HousetrailModel(QObject* parent = 0);
    ~HousetrailModel();

    Q_SLOT void append(const QVector<HouseMarker>& aHouseTrail);
    Q_INVOKABLE void clear();

    int rowCount(const QModelIndex& parent = QModelIndex()) const;

    bool contains(qint64 id) const;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    const HouseMarker* get(int idx) const;
    Q_INVOKABLE QString getHouseTitleById(qint64 id) const;
    HouseMarker* getHouseByTitle(const QString& title) const;

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    /**
     * Removes the first (oldes) entries, so that only m_maxSize items are left in the container
     */
    void limitSize();

    QList<HouseMarker*> m_Housetrails;
    QHash<qint64, HouseMarker*> m_Contained;

    int m_maxSize;
};

#endif // HOUSETRAILIMAGES_H
