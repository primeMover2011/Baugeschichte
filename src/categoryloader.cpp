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

#include "categoryloader.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QNetworkAccessManager>

CategoryLoader::CategoryLoader(QObject* parent)
    : QObject(parent)
    , m_manager(new QNetworkAccessManager(this))
    , m_loading(false)
{
    connect(m_manager, &QNetworkAccessManager::finished, this, &CategoryLoader::categoryLoaded);
}

void CategoryLoader::loadCategory(QString category)
{
    if (m_currentCategory == category) {
        return;
    }

    m_currentCategory = category;

    QString requestUrl("http://baugeschichte.at/api.php?action=ask&query=[[Kategorie:");
    requestUrl += category;
    requestUrl += QString("]]|%3FKoordinaten|%3ftitle&format=json");

    QNetworkRequest request = QNetworkRequest(QUrl(requestUrl));
    m_requests.append(request);
    m_manager->get(request);

    setLoading(!m_requests.isEmpty());
}

bool CategoryLoader::isLoading() const
{
    return m_loading;
}

void CategoryLoader::loadFromJsonText(const QByteArray& jsonText)
{
    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonText, &parseError);
    if (QJsonParseError::NoError != parseError.error) {
        qDebug() << parseError.errorString();
        return;
    }

    if (!jsonDoc.isObject()) {
        qDebug() << "no object..." << jsonDoc.toVariant();
    }

    QVector<HouseMarker> markers;
    QJsonObject infoObject = jsonDoc.object();
    QJsonObject result = infoObject["query"].toObject()["results"].toObject();
    for(QJsonValue house: result) {
        QJsonObject obj = house.toObject();
        HouseMarker newHouse;
        newHouse.setTitle(obj["fulltext"].toString());
        newHouse.setCategories(m_currentCategory);

        QJsonArray coordsArray = obj["printouts"].toObject()["Koordinaten"].toArray();
        QJsonObject coords = coordsArray[0].toObject();
        newHouse.setLocation(QGeoCoordinate(coords["lat"].toDouble(), coords["lon"].toDouble()));
        markers.push_back(newHouse);
    }

    if (!markers.isEmpty()) {
        emit newHousetrail(markers);
    }
}

void CategoryLoader::categoryLoaded(QNetworkReply* reply)
{

    if (reply == nullptr) {
        return;
    }

    const QNetworkRequest& request = reply->request();
    m_requests.removeOne(request);
    setLoading(!m_requests.isEmpty());

    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << Q_FUNC_INFO << reply->errorString();
        return;
    }

    const qint64 available = reply->bytesAvailable();
    if (available <= 0) {
        qDebug() << Q_FUNC_INFO << "reply is empty";
        return;
    }


    const QByteArray buffer = QString::fromUtf8(reply->readAll()).toLatin1();
    loadFromJsonText(buffer);
}

void CategoryLoader::setLoading(bool loading)
{
    if (loading == m_loading) {
        return;
    }

    m_loading = loading;
    emit isLoadingChanged(m_loading);
}
