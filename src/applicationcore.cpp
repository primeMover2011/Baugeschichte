/**
 ** This file is part of the Baugeschichte.at project.
 **
 ** The MIT License (MIT)
 **
 ** Copyright (c) 2016 Guenter Schwann
 **
 ** Permission is hereby granted, free of charge, to any person obtaining a copy
 ** of this software and associated documentation files (the "Software"), to deal
 ** in the Software without restriction, including without limitation the rights
 ** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ** copies of the Software, and to permit persons to whom the Software is
 ** furnished to do so, subject to the following conditions:
 **
 ** The above copyright notice and this permission notice shall be included in all
 ** copies or substantial portions of the Software.
 **
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 ** SOFTWARE.
 **/

#include "applicationcore.h"
#include "categoryloader.h"
#include "houselocationfilter.h"
#include "housemarkermodel.h"
#include "markerloader.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QScreen>
#include <QSortFilterProxyModel>
#include <QStandardPaths>
#include <QVector>
#include <QtQml>

#if defined(Q_OS_ANDROID)
#include <QAndroidJniObject>
#endif

#include <cmath>

ApplicationCore::ApplicationCore(QObject* parent)
    : QObject(parent)
    , m_view(new QQuickView())
    , m_houseMarkerModel(new HouseMarkerModel(this))
    , m_markerLoader(new MarkerLoader(this))
    , m_screenDpi(calculateScreenDpi())
    , m_mapProvider("osm")
    , m_selectedHouse("")
    , m_currentMapPosition(-1.0, -1.0)
    , m_showDetails(false)
    , m_housePositionLoader(new QNetworkAccessManager(this))
    , m_categoryLoader(new CategoryLoader(this))
    , m_categoryMarkerModel(new HouseMarkerModel(this))
    , m_showPosition(false)
    , m_followPosition(false)
{
    qRegisterMetaType<HouseMarker>("HouseMarker");
    qRegisterMetaType<QVector<HouseMarker>>("QVector<HouseMarker>");
    qmlRegisterType<HouseLocationFilter>("Baugeschichte", 1, 0, "HouseLocationFilter");
    qmlRegisterUncreatableType<HouseMarkerModel>("HouseMarkerModel", 1, 0, "HouseMarkerModel", "");

    m_view->setWidth(1024);
    m_view->setHeight(800);
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);

    QQmlEngine* engine = m_view->engine();
    QQmlContext* context = engine->rootContext();
    context->setContextProperty(QStringLiteral("appCore"), this);
    context->setContextProperty(QStringLiteral("markerLoader"), m_markerLoader);
    context->setContextProperty(QStringLiteral("houseTrailModel"), m_houseMarkerModel);
    context->setContextProperty(QStringLiteral("screenDpi"), m_screenDpi);
    context->setContextProperty(QStringLiteral("categoryLoader"), m_categoryLoader);

    connect(m_markerLoader, SIGNAL(newHousetrail(QVector<HouseMarker>)), m_houseMarkerModel,
        SLOT(append(QVector<HouseMarker>)));

    connect(m_categoryLoader, &CategoryLoader::newHousetrail, m_categoryMarkerModel, &HouseMarkerModel::append);

    connect(
        m_housePositionLoader, &QNetworkAccessManager::finished, this, &ApplicationCore::handleLoadedHouseCoordinates);

    loadMarkers();
}

ApplicationCore::~ApplicationCore()
{
    saveMarkers();
    delete (m_view);
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

QString ApplicationCore::selectedHouse() const
{
    return m_selectedHouse;
}

const QGeoCoordinate& ApplicationCore::currentMapPosition() const
{
    return m_currentMapPosition;
}

bool ApplicationCore::showDetails() const
{
    return m_showDetails;
}

void ApplicationCore::centerSelectedHouse()
{
    HouseMarker* house = m_houseMarkerModel->getHouseByTitle(m_selectedHouse);
    if (house != nullptr) {
        setCurrentMapPosition(house->location());
        emit requestFullZoomIn();
    } else {
        QString requestString
            = QString(
                  "http://baugeschichte.at/api.php?action=ask&query=[[%1]]|%3FKoordinaten|%3FPostleitzahl&format=json")
                  .arg(m_selectedHouse);
        QNetworkRequest request = QNetworkRequest(QUrl(requestString));
        m_housePositionLoader->get(request);
    }
}

void ApplicationCore::loadCategory(QString category)
{
    m_categoryMarkerModel->clear();
    m_categoryLoader->loadCategory(category);
}

QString ApplicationCore::routeKML() const
{
    return m_routeKML;
}

HouseMarkerModel* ApplicationCore::categoryHouses() const
{
    return m_categoryMarkerModel;
}

bool ApplicationCore::showPosition() const
{
    return m_showPosition;
}

void ApplicationCore::setShowPosition(bool showPosition)
{
    if (m_showPosition == showPosition) {
        return;
    }

    m_showPosition = showPosition;
    emit showPositionChanged(m_showPosition);
}

bool ApplicationCore::followPosition() const
{
    return m_followPosition;
}

void ApplicationCore::setFollowPosition(bool followPosition)
{
    if (m_followPosition == followPosition) {
        return;
    }

    m_followPosition = followPosition;
    emit followPositionChanged(m_followPosition);
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

void ApplicationCore::setSelectedHouse(const QString& selectedHouse)
{
    if (m_selectedHouse == selectedHouse) {
        return;
    }

    m_selectedHouse = selectedHouse;
    emit selectedHouseChanged(selectedHouse);

    if (m_selectedHouse.isEmpty()) {
        setShowDetails(false);
    }
}

void ApplicationCore::setCurrentMapPosition(const QGeoCoordinate& currentMapPosition)
{
    if (m_currentMapPosition == currentMapPosition) {
        return;
    }

    m_currentMapPosition = currentMapPosition;
    emit currentMapPositionChanged(currentMapPosition);
}

void ApplicationCore::setShowDetails(bool showDetails)
{
    if (m_showDetails == showDetails) {
        return;
    }

    m_showDetails = showDetails;
    emit showDetailsChanged(showDetails);
}

void ApplicationCore::setRouteKML(const QString& routeKML)
{
    if (m_routeKML == routeKML) {
        return;
    }

    m_routeKML = routeKML;
    emit routeKMLChanged(routeKML);
}

void ApplicationCore::doReloadUI()
{
    QQmlEngine* engine = m_view->engine();
    engine->clearComponentCache();
    m_view->setSource(mainQMLFile());
}

void ApplicationCore::handleLoadedHouseCoordinates(QNetworkReply* reply)
{
    if (reply == nullptr) {
        return;
    }

    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << Q_FUNC_INFO << "network error";
        reply->deleteLater();
        return;
    }

    const qint64 available = reply->bytesAvailable();
    if (available <= 0) {
        qDebug() << Q_FUNC_INFO << "No data in network reply";
        reply->deleteLater();
        return;
    }

    const QByteArray buffer = QString::fromUtf8(reply->readAll()).toLatin1();
    reply->deleteLater();
    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(buffer, &parseError);
    if (QJsonParseError::NoError != parseError.error) {
        qDebug() << Q_FUNC_INFO << parseError.errorString();
        return;
    }
    if (!jsonDoc.isObject()) {
        qDebug() << Q_FUNC_INFO << "no object..." << jsonDoc.toVariant();
        return;
    }

    QJsonObject infoObject = jsonDoc.object();

    QJsonObject resultsObject = infoObject["query"].toObject()["results"].toObject();
    if (resultsObject.isEmpty()) {
        qDebug() << Q_FUNC_INFO << "Error parsing the JSON object";
        return;
    }
    QJsonObject mainObject = (*resultsObject.begin()).toObject();
    QJsonObject printoutsObject = mainObject["printouts"].toObject();
    QJsonArray coordsArray = printoutsObject["Koordinaten"].toArray();

    if (coordsArray.isEmpty()) {
        qDebug() << Q_FUNC_INFO << "Error parsing the JSON object coords";
        return;
    }

    QJsonObject coordObject = coordsArray.at(0).toObject();
    QGeoCoordinate coord(coordObject["lat"].toDouble(), coordObject["lon"].toDouble());

    setCurrentMapPosition(coord);
    emit requestFullZoomIn();
}

QString ApplicationCore::mainQMLFile() const
{
    QFileInfo mainFile(QStringLiteral("../../Baugeschichte/src/main.qml"));
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
    QAndroidJniObject qtActivity = QAndroidJniObject::callStaticObjectMethod(
        "org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
    QAndroidJniObject resources = qtActivity.callObjectMethod("getResources", "()Landroid/content/res/Resources;");
    QAndroidJniObject displayMetrics
        = resources.callObjectMethod("getDisplayMetrics", "()Landroid/util/DisplayMetrics;");
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
    if (m_houseMarkerModel->rowCount() == 0) {
        return;
    }

    QJsonArray markerArray;
    for (int i = 0; i < m_houseMarkerModel->rowCount(); ++i) {
        QJsonObject object;
        object["title"] = m_houseMarkerModel->get(i)->title();
        object["coord_lat"] = m_houseMarkerModel->get(i)->location().latitude();
        object["coord_lon"] = m_houseMarkerModel->get(i)->location().longitude();
        object["category"] = m_houseMarkerModel->get(i)->categories();
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

    QVector<HouseMarker> houses;
    houses.reserve(array.size());
    Q_FOREACH (const QJsonValue& value, array) {
        QJsonObject object = value.toObject();
        HouseMarker house;
        house.setTitle(object["title"].toString());
        QGeoCoordinate coord(object["coord_lat"].toDouble(), object["coord_lon"].toDouble());
        house.setLocation(coord);
        house.setCategories(object["category"].toString());
        houses.push_back(house);
    }

    m_houseMarkerModel->append(houses);
}
