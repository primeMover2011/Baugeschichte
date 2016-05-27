#include "applicationcore.h"

#include <QGuiApplication>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationDisplayName(QStringLiteral("Baugeschichte.at"));

    ApplicationCore appCore;
    appCore.showView();

    return app.exec();
}
