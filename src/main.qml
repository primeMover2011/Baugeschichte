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

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls.Styles 1.4
//import QtQuick.Controls.Material 2.0
import QtPositioning 5.5
import QtLocation 5.5
import Qt.labs.settings 1.0
import "./"

Item {
    id: root

    width: 1024
    height: 800

    visible: true

//    Material.accent: Material.LightBlue

    readonly property bool loading: (uiStack.currentItem && uiStack.currentItem.loading) ||
                                    markerLoader.loading ||
                                    categoryLoader.isLoading || routeLoader.loading

    property MapComponent mainMap: null

    PositionSource {
        id: positionCheck
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        active: false
    }

    Shortcut {
        id: reloadAction
        sequence: "Ctrl+R"
        onActivated: {
            appCore.reloadUI();
        }
    }
    Shortcut {
        id: settingsMenuAction
        sequence: "Ctrl+M"
        onActivated: {
            uiStack.push({
                             item: Qt.resolvedUrl("SettingsView.qml")
                         });
        }
    }

    Item {
        id: toolBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.buttonHeight

        Rectangle {
            id: toolBarBackground
            anchors.fill: parent
            color: "#f8f8f8"
        }

        RowLayout {
            anchors.fill: parent

            ToolbarButton {
                id: mapButton
                source: "resources/icon-map.svg"
                onClicked: {
                    if (appCore.showDetails) {
                        appCore.showDetails = false;
                        return;
                    }

                    mainMap.resetToMainModel();
                    uiStack.pop(null);
                    appCore.routeKML = "";
                    routeLoader.reset();
                }
            }

            ToolbarButton {
                id: searchButton
                source: "resources/icon-search.svg"
                onClicked: {
                    mainMap.resetToMainModel();
                    appCore.selectedHouse = "";
                    appCore.showDetails = false;
                    appCore.routeKML = "";
                    routeLoader.routeHouses = [];
                    uiStack.pop(null);
                    uiStack.push({
                                     item: Qt.resolvedUrl("SearchPage.qml")
                                 })
                }
            }

            ToolbarButton {
                id: categoriesButton
                source: "resources/icon-categories.svg"
                onClicked: {
                    mainMap.useCategoryModel();
                    appCore.selectedHouse = "";
                    appCore.showDetails = false;
                    appCore.routeKML = "";
                    routeLoader.routeHouses = [];
                    uiStack.pop(null);
                    uiStack.push({
                                     item: Qt.resolvedUrl("CategoryselectionView.qml")
                                 })
                }
            }

            ToolbarButton {
                id: routesButton
                source: "resources/icon-route.svg"
                onClicked: {
                    mainMap.resetToMainModel();
                    appCore.selectedHouse = "";
                    appCore.showDetails = false;
                    appCore.routeKML = "";
                    routeLoader.routeHouses = [];
                    uiStack.push({
                                     item: Qt.resolvedUrl("RouteView.qml")
                                 })
                }
            }

            ToolbarButton {
                id: followMeButton
                source: iconFromState()
                enabled: positionCheck.valid

                onClicked: {
                    if (!appCore.showPosition) {
                        appCore.showPosition = true;
                        appCore.followPosition = false;
                    } else {
                        if (appCore.followPosition) {
                            appCore.showPosition = false;
                        } else {
                            appCore.followPosition = true;
                        }
                    }
                }

                function iconFromState() {
                    if (!appCore.showPosition) {
                        return "qrc:/resources/gps_off.svg"
                    } else {
                        if (appCore.followPosition) {
                            return "qrc:/resources/gps_follow.svg"
                        } else {
                            return "qrc:/resources/gps_on.svg"
                        }
                    }
                }
            }
        }

        Item {
            height: toolBar.height
            width: height
            anchors.right: parent.right
            anchors.top: parent.top

            LoadIndicator {
                id: busyIndicator
                anchors.fill: parent
                anchors.margins: toolBar.height * 0.1
                style: BusyIndicatorStyle {
                    indicator: Image {
                        visible: control.running
                        source: "resources/spinner.png"
                        RotationAnimator on rotation {
                            running: control.running
                            loops: Animation.Infinite
                            duration: 1000
                            from: 0 ; to: 360
                        }
                    }
                }

//                anchors.verticalCenter: parent.verticalCenter
//                anchors.right: parent.right
//                anchors.rightMargin: toolBar.height * 0.1

//                height: toolBar.height * 0.8
//                width: height

                running: root.loading
            }
        }
    }

    Loader {
        id: shutDownDialog

        function open() {
            if (source == "") {
                source = "ShutDownDialog.qml";
            }
            item.visible = true;
        }
    }

    Rectangle {
        id: background
        color: "#060606"
        anchors.fill: parent
        anchors.topMargin: toolBar.height

        focus: true
        Keys.onReleased: {
            console.log("Keys.onrelease")
            console.log("uiStack Depth:" + uiStack.depth)
            if (event.key === Qt.Key_Back) {
                event.accepted = true
                if (uiStack.currentItem.detailsOpen) {
                    appCore.showDetails = false;
                } else {
                    if (uiStack.depth > 1) {
                        uiStack.pop()
                    } else {
                        shutDownDialog.open();
                    }
                }
            }
// settings disabled for now
//            if (event.key === Qt.Key_Menu) {
//                event.accepted = true;
//                uiStack.push({
//                                 item: Qt.resolvedUrl("SettingsView.qml")
//                             });
//            }
        }
    }

    RouteLoader {
        id: routeLoader
    }

    Controls1.StackView {
        id: uiStack
        anchors.fill: background
        objectName: "theStackView"

        initialItem: loader_mapOfEurope

        Component {
            id: component_mapOfEurope

            BaseView {
                id: mapItem

                property bool splitScreen: width > height
                readonly property bool detailsOpen: details.visible

                loading: details.item ? details.item.loading : false

                MapComponent {
                    id: mapOfEurope

                    width: splitScreen ? details.x : parent.width
                    height: parent.height

                    visible: parent.splitScreen || !details.visible

                    center: QtPositioning.coordinate(settings.lastSeenLat, settings.lastSeenLon)
                    zoomLevel: settings.lastZoomLevel
                    Component.onCompleted: {
                        root.mainMap = mapOfEurope;
                    }
                    Component.onDestruction: {
                        settings.lastSeenLat = mapOfEurope.center.latitude
                        settings.lastSeenLon = mapOfEurope.center.longitude
                        settings.lastZoomLevel = mapOfEurope.zoomLevel
                    }

                    Timer {
                        // workaround for bug QTBUG-52030 / QTBUG-55424
                        interval: 5
                        running: true
                        onTriggered: {
                            mapOfEurope.center = QtPositioning.coordinate(settings.lastSeenLat, settings.lastSeenLon);
                        }
                    }
                }

                Loader {
                    id: details

                    x: visible ? (parent.splitScreen ? parent.width / 2 : 0) : parent.width
                    width: parent.splitScreen ? parent.width / 2 : parent.width
                    height: parent.height

                    clip: true
                    visible: appCore.showDetails
                    onVisibleChanged: {
                        if (visible && source == "") {
                            setSource("DetailsView.qml");
                        }
                    }
                }
            }
        }
        Loader {
            id: loader_mapOfEurope
            sourceComponent: component_mapOfEurope
            readonly property bool loading: item ? item.loading : false
            readonly property bool detailsOpen: item ? item.detailsOpen : false

            function reloadMapItem() {
                loader_mapOfEurope.sourceComponent = undefined;
                loader_mapOfEurope.sourceComponent = component_mapOfEurope;
            }

            Connections {
                target: appCore
                onMapProviderChanged: {
                    loader_mapOfEurope.reloadMapItem();
                }
            }
        }
    }

    Settings {
        id: settings
        property double lastSeenLat: 47.0666667 // graz
        property double lastSeenLon: 15.45
        property double lastZoomLevel: 16 // default zoom level
    }
}
