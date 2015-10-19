#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include "dialog.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    HousetrailModel aHouseTrailImages;
    Dialog dialog(&aHouseTrailImages);
//    channel.registerObject(QStringLiteral("dialog"), &dialog);
    context->setContextProperty(QStringLiteral("dialog"), &dialog);
    context->setContextProperty(QStringLiteral("houseTrailModel"), &aHouseTrailImages);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));



    return app.exec();
}
