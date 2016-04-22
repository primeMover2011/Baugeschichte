#include "dialog.h"
#include "housetrailimages.h"
#include "houselocationfilter.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>
#include <QSortFilterProxyModel>
#include <QScreen>

#if defined(Q_OS_ANDROID)
    #include <QAndroidJniObject>
#endif

int main(int argc, char *argv[])
{
    qRegisterMetaType<HouseTrail>("HouseTrail");
    qRegisterMetaType<QVector<HouseTrail> >("QVector<HouseTrail>");
    qmlRegisterType<HouseLocationFilter>("Baugeschichte", 1, 0, "HouseLocationFilter");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    HousetrailModel aHouseTrailImages;
    Dialog dialog(&aHouseTrailImages);

    QSortFilterProxyModel detailsProxyModel;
    detailsProxyModel.setFilterRole(HousetrailModel::HousetrailRoles::CategoryRole);
//                MyViewModel::MyViewModel_Roles::MyViewModel_Roles_Details);
    //detailsProxyModel->setFilterRegExp( "^\\S+$" );
    detailsProxyModel.setSourceModel(&aHouseTrailImages);

     qreal dpi;
     #if defined(Q_OS_ANDROID)
        QAndroidJniObject qtActivity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
        QAndroidJniObject resources = qtActivity.callObjectMethod("getResources","()Landroid/content/res/Resources;");
        QAndroidJniObject displayMetrics = resources.callObjectMethod("getDisplayMetrics","()Landroid/util/DisplayMetrics;");
        int density = displayMetrics.getField<int>("densityDpi");
        dpi = density;
//        qreal dpiRef = 132; //reference device dpi (ipad);
//        if(densitydpi > 0 && dpiRef > 0)
//                density = densitydpi / dpiRef;
     #else
         dpi = app.primaryScreen()->physicalDotsPerInch() * app.devicePixelRatio();
    #endif

    context->setContextProperty(QStringLiteral("dialog"), &dialog);
    context->setContextProperty(QStringLiteral("houseTrailModel"), &aHouseTrailImages);
    context->setContextProperty(QStringLiteral("filteredTrailModel"), &detailsProxyModel);
    context->setContextProperty(QStringLiteral("screenDpi"), dpi);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
