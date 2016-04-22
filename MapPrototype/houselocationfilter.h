#ifndef HOUSELOCATIONFILTER_H
#define HOUSELOCATIONFILTER_H

#include <QGeoCoordinate>
#include <QSortFilterProxyModel>

/**
 * @brief The HouseLocationFilter filters the HouseTrailModel by location and radius
 */
class HouseLocationFilter : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QGeoCoordinate location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(double radius READ radius WRITE setRadius NOTIFY radiusChanged)

public:
    HouseLocationFilter(QObject* parent = nullptr);

    double radius() const;
    const QGeoCoordinate& location() const;

public slots:
    void setRadius(double radius);
    void setLocation(const QGeoCoordinate& location);

signals:
    void radiusChanged(double radius);
    void locationChanged(const QGeoCoordinate& location);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private:
    double m_radius;
    QGeoCoordinate m_location;
};

#endif // HOUSELOCATIONFILTER_H
