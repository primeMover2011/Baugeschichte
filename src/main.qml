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
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtPositioning 5.5
import QtLocation 5.5
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import "./"

Item {
    id: root

    width: 1024
    height: 800

    visible: true

    readonly property bool loading: uiStack.currentItem.loading || markerLoader.loading ||
                                    categoryLoader.isLoading || routeLoader.loading

    property MapComponent mainMap: null

    ExclusiveGroup {
          id: categoryGroup
    }

    PositionSource {
        id: thePosition
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        active: false
    }

    DensityHelpers {
        id: localHelper
    }

    Action {
        id: reloadAction
        shortcut: "Ctrl+R"
        onTriggered: {
            appCore.reloadUI();
        }
    }
    Action {
        id: settingsMenuAction
        shortcut: "Ctrl+M"
        onTriggered: {
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
        height: localHelper.dp(50)

        Rectangle {
            id: toolBarBackground
            anchors.fill: parent
            color: "#f8f8f8"
        }

        RowLayout {
            anchors.fill: parent

            ToolbarButton {
                id: mapButton
                source: "resources/Map-icon.svg"
                onClicked: {
                    mainMap.resetToMainModel();
                    uiStack.pop(null);
                    appCore.showDetails = false;
                    appCore.routeKML = "";
                    routeLoader.routeHouses = [];
                }
            }

            ToolbarButton {
                id: searchButton
                source: "resources/System-search.svg"
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
                source: "resources/Edit-find-cats.svg"
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
                source: "resources/Edit-check-sheet.svg"
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
                id: theFollowMeButton
                source: "qrc:/resources/Ic_gps_" + (isActive ? "not_fixed" : "off") + "_48px.svg"
                enabled: thePosition.valid

                property bool isActive: false

                onClicked: {
                    isActive = !isActive;
                }
            }
        }

        Item {
            id: loadingIndicator
            width: height
            height: toolBar.height

            anchors.right: parent.right
            anchors.top: parent.top

            BusyIndicator {
                anchors.fill: parent
                anchors.margins: toolBar.height * 0.1

                running: root.loading

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
            }
        }
    }

    //    PositionSource
    property variant locationGraz: QtPositioning.coordinate(47.0666667, 15.45)

    MessageDialog {
        id: shutDownDialog
        icon: StandardIcon.Question
        standardButtons: StandardButton.Yes | StandardButton.No
        modality: Qt.WindowModal
        title: qsTr("Baugeschichte App beenden?")
        onButtonClicked: console.log("clicked button " + clickedButton)
        onYes: Qt.quit()
        onNo: visible = false
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
                        shutDownDialog.visible = true
                    }
                }
            }
            if (event.key === Qt.Key_Menu) {
                event.accepted = true;
                uiStack.push({
                                 item: Qt.resolvedUrl("SettingsView.qml")
                             });
            }
        }
    }

    RouteLoader {
        id: routeLoader
    }

    StackView {
        id: uiStack
        anchors.fill: background
        objectName: "theStackView"

        initialItem: loader_mapOfEurope
        onDepthChanged: {
            console.log("Depth changed:" + depth)
        }

        Component {
            id: component_mapOfEurope

            BaseView {
                id: mapItem

                property bool splitScreen: width > height
                readonly property bool detailsOpen: details.visible

                loading: details.loading

                MapComponent {
                    id: mapOfEurope

                    width: splitScreen ? details.x : parent.width
                    height: parent.height

                    followMe: theFollowMeButton.isActive
                    visible: parent.splitScreen || !details.visible

                    Settings {
                        id: settings
                        property alias lastSeenLat: mapOfEurope.center.latitude
                        property alias lastSeenLon: mapOfEurope.center.longitude
                        property alias lastZoomLevel: mapOfEurope.zoomLevel
                    }

                    center: locationGraz
                    Component.onCompleted: {
                        root.mainMap = mapOfEurope;
                    }
                }

                DetailsView {
                    id: details

                    x: visible ? (parent.splitScreen ? parent.width / 2 : 0) : parent.width
                    width: parent.splitScreen ? parent.width / 2 : parent.width
                    height: parent.height

                    clip: true
                    visible: appCore.showDetails
                    searchFor: appCore.selectedHouse
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
}
