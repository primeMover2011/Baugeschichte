#include "applicationcore.h"
#include "markerloader.h"
#include "houselocationfilter.h"
#include "housetrailimages.h"

#include <QDebug>
#include <QGuiApplication>
#include <QFileInfo>
#include <QtQml>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QScreen>
#include <QSortFilterProxyModel>
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
}

ApplicationCore::~ApplicationCore()
{
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
