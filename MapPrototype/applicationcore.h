#ifndef APPLICATIONCORE_H
#define APPLICATIONCORE_H

#include <QObject>

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
    Q_OBJECT
public:
    explicit ApplicationCore(QObject *parent = 0);
    ~ApplicationCore();

    void showView();

public slots:
    void reloadUI();

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
};

#endif // APPLICATIONCORE_H
