/**
 ** This file is part of the Baugeschichte.at project.
 **
 ** The MIT License (MIT)
 **
 ** Copyright (c) 2015 primeMover2011
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

import QtQuick 2.4
import QtQuick.Controls 1.4
import QtLocation 5.6
import QtPositioning 5.6
import "./"
import Baugeschichte 1.0

BaseView {
    id: root

    property bool autoUpdatePois: true
    property double radius: 100

    property alias center: map.center
    property alias zoomLevel: map.zoomLevel

    function resetToMainModel()
    {
        housetrailMapItems.model = locationFilter;
    }
    function useCategoryModel()
    {
        housetrailMapItems.model = categoryModel;
    }

    function updateRadius() {
        scaleItem.calculateScale();
        if (autoUpdatePois) {
            var coord1 = map.toCoordinate(Qt.point(0, 0))
            var coord2 = map.toCoordinate(Qt.point(map.width-1, map.height-1))
            var dist1 = Math.abs(coord1.latitude - coord2.latitude)
            var dist2 = Math.abs(coord1.longitude - coord2.longitude)
            var dist = (dist1 > dist2) ? dist1 : dist2;
            var radius = dist / 2.0;

            markerLoader.radius = radius;
            root.radius = map.center.distanceTo(coord1);

            markerLoader.loadAll = map.zoomLevel > 17;

            if (map.zoomLevel < 18) {
                var coord3 = map.toCoordinate(Qt.point(map.markerSize * 1.1, 0))
                var markerDist = coord1.distanceTo(coord3)
                locationFilter.minDistance = markerDist;
            } else {
                locationFilter.minDistance = 1e-3
            }
        }
    }

    HouseLocationFilter {
        id: locationFilter
        sourceModel: houseTrailModel
        location: map.center
        radius: root.radius
        unfilteredHouseTitle: appCore.selectedHouse
    }

    HouseLocationFilter {
        id: categoryModel
        sourceModel: appCore.categoryHouses
        location: map.center
        radius: root.radius
        unfilteredHouseTitle: appCore.selectedHouse
        minDistance: locationFilter.minDistance
    }

    DensityHelpers {
        id: localHelper
    }

    PositionSource {
        id: myPosition
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        active: appCore.showPosition
        updateInterval: 1500

        // even when not following - jump to current position on first position reveice
        property bool firstUpdate: true
        onFirstUpdateChanged: console.log("firstUpdate: "+firstUpdate)
        onActiveChanged: {
            if (active) {
                firstUpdate = true;
            }
        }

        onPositionChanged: {
            if (appCore.followPosition || firstUpdate) {
                firstUpdate = false;
                map.center = myPosition.position.coordinate
            }
        }
    }

    Map {
        id: map

        anchors.centerIn: parent
        width: parent.width / scale
        height: parent.height / scale
        scale: screenDpi > 200 ? 2 :1

        property MarkerLabel markerLabel

        readonly property int markerSize: localHelper.dp(50) / map.scale
        readonly property real defaultZoomLevel: 16

        center: QtPositioning.coordinate(47.0666667, 15.45)
        onCenterChanged: {
            if (autoUpdatePois) {
                markerLoader.setLocation(center.latitude, center.longitude);
            }
            appCore.currentMapPosition = center;
        }

        zoomLevel: defaultZoomLevel

        onZoomLevelChanged: {
            root.updateRadius();
        }
        onWidthChanged: {
            root.updateRadius();
        }
        onHeightChanged: {
            root.updateRadius();
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onPressed: {
                appCore.followPosition = false;
                mouse.accepted = false;
            }
            onClicked: {
                appCore.selectedHouse = "";
            }
        }

        plugin: initPlugin()
        function initPlugin() {
//            return appCore.mapProvider === "osm" ? osmPlugin : mapBoxPlugin;
            return mapBoxPlugin;
        }
        Plugin {
            id: osmPlugin
            name: "osm"
        }
        Plugin {
            id: mapBoxPlugin
            name: "mapbox"
            PluginParameter {
                name: "mapbox.map_id"
                value: "mapbox.streets"
            }
            PluginParameter {
                name: "mapbox.access_token"
                value: "pk.eyJ1IjoiYmF1Z2VzY2hpY2h0ZSIsImEiOiJjaXFqdXU4OG8wMDAxaHltYnVmcHV2bjVjIn0.C2joRbxcvAQGbF9I-KhgnA"
            }
        }

        RouteLine {
            source: appCore.routeKML !== "" ? "http://baugeschichte.at/" + appCore.routeKML : ""
        }

        MapItemView {
            id: housetrailMapItems
            model: locationFilter

            delegate: MapQuickItem {
                id: mqItem
                coordinate: QtPositioning.coordinate(coord.latitude,
                                                     coord.longitude)

                anchorPoint.x: image.width * 0.5
                anchorPoint.y: image.height

                sourceItem: Item {
                    id: sourceItem
                    width: image.width
                    height: image.height

                    Image {
                        id: image
                        antialiasing: true
                        source: getSource()
                        width: map.markerSize
                        height: map.markerSize

                        sourceSize: Qt.size(width, height)
                        fillMode: Image.PreserveAspectFit

                        function getSource() {
                            if (title === appCore.selectedHouse) {
                                return "resources/marker-blue.svg";
                            }
                            if (routeLoader.isRouteHouse(title)) {
                                return "resources/marker-red.svg";
                            }
                            return "resources/marker.svg"
                        }

                        Connections {
                            target: routeLoader
                            onLoadingChanged: {
                                if (!routeLoader.loading) {
                                    image.source = Qt.binding(function(){return image.getSource();});
                                }
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: image
                        onPressed: changeCurrentItem()

                        function changeCurrentItem() {
                            if (map.markerLabel) {
                                map.markerLabel.destroy();
                            }

                            var component = Qt.createComponent("MarkerLabel.qml");
                            map.markerLabel = component.createObject(map);
                            map.markerLabel.mapItem = map;
                            map.addMapItem(map.markerLabel);

                            map.markerLabel.coordinate = mqItem.coordinate;
                            map.markerLabel.z = 9999;
                            map.markerLabel.title = title
                            map.markerLabel.visible = true;

                            appCore.selectedHouse = title;
                        }
                    }
                }
            }
        }

        PositionIndicator {
            id: positionCircle
            positionSource: myPosition
            scale: 1 / map.scale
            visible: appCore.showPosition
        }

        Component.onCompleted: {
            zoomLevel = defaultZoomLevel;
            root.updateRadius();
        }
    }

    Slider {
        id: zoomSlider
        minimumValue: map.minimumZoomLevel
        maximumValue: map.maximumZoomLevel
        anchors.margins: 10
        anchors.bottom: scaleItem.top
        anchors.top: parent.top
        anchors.right: parent.right
        orientation: Qt.Vertical
        value: map.zoomLevel
        onValueChanged: {
            map.zoomLevel = value
        }
    }

    MapScale {
        id: scaleItem
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20

        mapItem: map
    }

    Connections {
        target: routeLoader
        onLoadingChanged: {
            if (!routeLoader.loading) {
                var newRouteHouses = [];
                for (var i=0; i< routeLoader.routeHouses.length; ++i) {
                    newRouteHouses.push(routeLoader.routeHouses[i].title)
                }
                locationFilter.setRouteHouses(newRouteHouses);

                map.visibleRegion = routeLoader.routeArea;
            }
        }
    }

    Connections {
        target: appCore
        onSelectedHouseChanged: {
            if (appCore.selectedHouse === "" && map.markerLabel) {
                map.markerLabel.destroy();
            }
        }
        onCurrentMapPositionChanged: {
            if (map.center !== appCore.currentMapPosition) {
                map.center = appCore.currentMapPosition;
            }
        }
        onRequestFullZoomIn: {
            if (map.zoomLevel < 18) {
                map.zoomLevel = 19;
            }
        }
    }
}
