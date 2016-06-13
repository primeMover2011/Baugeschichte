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
    Q_OBJECT
public:
    explicit ApplicationCore(QObject *parent = 0);
    ~ApplicationCore();

    void showView();
    Q_INVOKABLE void reloadUI();

    QString mapProvider() const;
    void setMapProvider(QString mapProvider);

signals:
    void mapProviderChanged(QString mapProvider);

private slots:
    void doReloadUI();

private:
    QString mainQMLFile() const;
    int calculateScreenDpi() const;

    QQuickView* m_view;
    HousetrailModel* m_houseTrailModel;
    MarkerLoader* m_markerLoader;
    QSortFilterProxyModel* m_detailsProxyModel;
    int m_screenDpi;
    QString m_mapProvider;
};

#endif // APPLICATIONCORE_H
