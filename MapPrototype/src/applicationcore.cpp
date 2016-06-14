#include "applicationcore.h"
#include "markerloader.h"
#include "houselocationfilter.h"
#include "housetrailimages.h"

#include <QDebug>
#include <QGuiApplication>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QtQml>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QScreen>
#include <QSortFilterProxyModel>
#include <QStandardPaths>
#include <QVector>

#if defined(Q_OS_ANDROID)
    #include <QAndroidJniObject>
#endif

#include <cmath>

ApplicationCore::ApplicationCore(QObject *parent)
    : QObject(parent)
    , m_view(new QQuickView())
    , m_houseTrailModel(new HousetrailModel(this))
    , m_markerLoader(new MarkerLoader(this))
    , m_detailsProxyModel(new QSortFilterProxyModel(this))
    , m_screenDpi(calculateScreenDpi())
    , m_mapProvider("osm")
{
    qRegisterMetaType<HouseTrail>("HouseTrail");
    qRegisterMetaType<QVector<HouseTrail> >("QVector<HouseTrail>");
    qmlRegisterType<HouseLocationFilter>("Baugeschichte", 1, 0, "HouseLocationFilter");

    m_view->setWidth(1024);
    m_view->setHeight(800);
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);

    m_detailsProxyModel->setFilterRole(HousetrailModel::HousetrailRoles::CategoryRole);
    m_detailsProxyModel->setSourceModel(m_houseTrailModel);

    QQmlEngine* engine = m_view->engine();
    QQmlContext *context = engine->rootContext();
    context->setContextProperty(QStringLiteral("appCore"), this);
    context->setContextProperty(QStringLiteral("markerLoader"), m_markerLoader);
    context->setContextProperty(QStringLiteral("houseTrailModel"), m_houseTrailModel);
    context->setContextProperty(QStringLiteral("filteredTrailModel"), m_detailsProxyModel);
    context->setContextProperty(QStringLiteral("screenDpi"), m_screenDpi);

    connect(m_markerLoader, SIGNAL(newHousetrail(QVector<HouseTrail>)),
            m_houseTrailModel, SLOT(append(QVector<HouseTrail>)));

    loadMarkers();
}

ApplicationCore::~ApplicationCore()
{
    saveMarkers();
    delete(m_view);
}

void ApplicationCore::showView()
{
    m_view->setSource(mainQMLFile());
    m_view->show();
}

void ApplicationCore::reloadUI()
{
    QMetaObject::invokeMethod(this, "doReloadUI", Qt::QueuedConnection);
}

QString ApplicationCore::mapProvider() const
{
    return m_mapProvider;
}

void ApplicationCore::setMapProvider(QString mapProvider)
{
    if (mapProvider == m_mapProvider) {
        return;
    }

    m_mapProvider = mapProvider;
    emit mapProviderChanged(m_mapProvider);
}

void ApplicationCore::handleApplicationStateChange(Qt::ApplicationState state)
{
    switch (state) {
    case Qt::ApplicationHidden:
    case Qt::ApplicationInactive:
        saveMarkers();
        break;
    case Qt::ApplicationActive:
        loadMarkers();
        break;
    default:
        break;
    }
}

void ApplicationCore::doReloadUI()
{
    QQmlEngine* engine = m_view->engine();
    engine->clearComponentCache();
    m_view->setSource(mainQMLFile());
}

QString ApplicationCore::mainQMLFile() const
{
    QFileInfo mainFile(QStringLiteral("../Baugeschichte/MapPrototype/main.qml"));
    if (mainFile.exists()) {
        qDebug() << "Load UI from" << mainFile.absoluteFilePath();
        return mainFile.absoluteFilePath();
    } else {
        qDebug() << "Load UI from embedded resource";
        return QStringLiteral("qrc:/main.qml");
    }
}

int ApplicationCore::calculateScreenDpi() const
{
#if defined(Q_OS_ANDROID)
    QAndroidJniObject qtActivity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
    QAndroidJniObject resources = qtActivity.callObjectMethod("getResources","()Landroid/content/res/Resources;");
    QAndroidJniObject displayMetrics = resources.callObjectMethod("getDisplayMetrics","()Landroid/util/DisplayMetrics;");
    int density = displayMetrics.getField<int>("densityDpi");
    return density;
#else
    QGuiApplication* uiApp = qobject_cast<QGuiApplication*>(qApp);
    qreal dpi = uiApp->primaryScreen()->physicalDotsPerInch() * uiApp->devicePixelRatio();
    if (uiApp) {
        return static_cast<int>(floor(dpi));
    } else {
        return 96;
    }
#endif
}

void ApplicationCore::saveMarkers()
{
    if (m_houseTrailModel->rowCount() == 0) {
        return;
    }

    QJsonArray markerArray;
    for (int i=0; i< m_houseTrailModel->rowCount(); ++i) {
        QJsonObject object;
        object["dbId"] = m_houseTrailModel->get(i)->dbId();
        object["title"] = m_houseTrailModel->get(i)->houseTitle();
        object["coord_lat"] = m_houseTrailModel->get(i)->theLocation().latitude();
        object["coord_lon"] = m_houseTrailModel->get(i)->theLocation().longitude();
        object["category"] = m_houseTrailModel->get(i)->categories();
        object["geohash"] = m_houseTrailModel->get(i)->geoHash();
        markerArray.append(object);
    }

    QString markerFile = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir dir;
    dir.mkpath(markerFile);
    markerFile += QStringLiteral("/markers.json");

    QJsonDocument doc(markerArray);
    QFile file(markerFile);
    file.open(QIODevice::WriteOnly);
    if (!file.isOpen()) {
        qWarning() << Q_FUNC_INFO << "unable to open file" << markerFile;
    }
    file.write(doc.toJson());
}

void ApplicationCore::loadMarkers()
{
    QString markerFile = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    markerFile += QStringLiteral("/markers.json");

    QFile file(markerFile);
    if (!file.exists()) {
        qWarning() << Q_FUNC_INFO << "file does not exist" << markerFile;
        return;
    }
    file.open(QIODevice::ReadOnly);
    if (!file.isOpen()) {
        qWarning() << Q_FUNC_INFO << "unable to open file" << markerFile;
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonArray array = doc.array();

    QVector<HouseTrail> houses;
    houses.reserve(array.size());
    Q_FOREACH(const QJsonValue& value, array) {
        QJsonObject object = value.toObject();
        HouseTrail house;
        house.setDbId(object["dbId"].toInt());
        house.setHouseTitle(object["title"].toString());
        QGeoCoordinate coord(object["coord_lat"].toDouble(), object["coord_lon"].toDouble());
        house.setTheLocation(coord);
        house.setCategories(object["category"].toString());
        house.setGeoHash(object["geohash"].toString());
        houses.push_back(house);
    }

    m_houseTrailModel->append(houses);
}
