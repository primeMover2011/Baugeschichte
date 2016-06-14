#ifndef APPLICATIONCORE_H
#define APPLICATIONCORE_H

#include <QObject>
#include <QString>

class MarkerLoader;
class HousetrailModel;

//class QQmlApplicationEngine;
class QQuickView;
class QSortFilterProxyModel;

/**
 * The central hub for QML <-> C++ communication
 */
class ApplicationCore : public QObject
{
    Q_PROPERTY(QString mapProvider READ mapProvider WRITE setMapProvider NOTIFY mapProviderChanged)
    Q_PROPERTY(qint64 selectedHouseId READ selectedHouseId WRITE setSelectedHouseId NOTIFY selectedHouseIdChanged)
    Q_OBJECT
public:
    explicit ApplicationCore(QObject *parent = 0);
    ~ApplicationCore();

    void showView();
    Q_INVOKABLE void reloadUI();

    QString mapProvider() const;
    void setMapProvider(QString mapProvider);

    qint64 selectedHouseId() const;

public slots:
    void handleApplicationStateChange(Qt::ApplicationState state);

    void setSelectedHouseId(qint64 selectedHouseId);

signals:
    void mapProviderChanged(QString mapProvider);

    void selectedHouseIdChanged(qint64 selectedHouseId);

private slots:
    void doReloadUI();

private:
    QString mainQMLFile() const;
    int calculateScreenDpi() const;
    void saveMarkers();
    void loadMarkers();

    QQuickView* m_view;
    HousetrailModel* m_houseTrailModel;
    MarkerLoader* m_markerLoader;
    QSortFilterProxyModel* m_detailsProxyModel;
    int m_screenDpi;
    QString m_mapProvider;
    qint64 m_selectedHouseId;
};

#endif // APPLICATIONCORE_H
