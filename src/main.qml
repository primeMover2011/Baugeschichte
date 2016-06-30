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

    readonly property bool loading: uiStack.currentItem.loading || markerLoader.loading || routeLoader.loading

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
                    filteredTrailModel.setFilterWildcard("");
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

/*    menuBar: MenuBar {
        id: mainMenuBar
        Menu {
            id: categoryMenu
            title: "Categories"
            function createMenu() {
                clear()
                addCategory("Keine Kategorie")
                for (var i = 0; i < categoryModel.count; i++) {
                    var catName = categoryModel.get(i).category

                    //                    var catName = categoryModel[i].category
                    addCategory(catName)
                }
            }

            function selectCategory(theCat) {
                //                filteredTrailModel.setFilterWildcard("Geschichte");
                if (theCat.indexOf("Keine") > -1)
                    theCat = ""
                filteredTrailModel.setFilterWildcard(theCat)
            }
            function addCategory(theName) {
                var item = addItem(theName)
                item.checkable = true
                item.exclusiveGroup = categoryGroup
                //console.log(theName);
                item.triggered.connect(function () {
                    selectCategory(theName)
                })
            }
        }
    }//<--menuBar
*/

    ListModel {
        id: categoryModel
        Component.onCompleted: {
            var leCategories = '[{"category":"Ab 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Ab 2000 restauriert","color":"#ff0000"},{"category":"Aktuell (Graz)","color":"#ff0099"},{"category":"Aktuell (Salzburg)","color":"#ff0000"},{"category":"Bis 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Gedenkst\u00e4tten","color":"#ff0000"},{"category":"Geschichte","color":"#ff0000"},{"category":"Historische Ansicht vorhanden","color":"#ff0000"},{"category":"Leerstand","color":"#ff0000"},{"category":"Stadttore","color":"#ff0000"},{"category":"Gef\u00e4hrdet","color":"#ff0000"}]'

            var jsonCats = JSON.parse(leCategories)
            if (jsonCats.errors !== undefined)
                console.log("Error fetching searchresults: " + jsonCats.errors[0].message)
            else {

                for (var key in jsonCats) {

                    var jsonObject = jsonCats[key]
                    jsonObject.selected = false
                    categoryModel.append(jsonObject)
                }
            }
            //categoryMenu.createMenu()
        }
    }

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
        anchors.fill: uiStack
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

                // used to fit screen to route
                Map {
                    id: zoomMap
                    anchors.fill: parent
                    visible: false
                    enabled: false

                    plugin: initPlugin()
                    function initPlugin() {
                        return appCore.mapProvider === "osm" ? osmPlugin : mapBoxPlugin;
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
                            value: "primemover.c5fe94e8"
                        }
                        PluginParameter {
                            name: "mapbox.access_token"
                            value: "pk.eyJ1IjoicHJpbWVtb3ZlciIsImEiOiIzNjFlYWNjZmZhMjAyNGFhMWQ0NDM0ZDIyMTE4YmEyMCJ9.d5wi3uI5VayKiniPnkxojg"
                        }
                    }

                    RouteLine {
                        source: appCore.routeKML !== "" ? "http://baugeschichte.at/" + appCore.routeKML : ""

                        onLoadingChanged: {
                            if (loading || pathLength() === 0) {
                                return;
                            }


                            zoomMap.fitViewportToMapItems();
                            mapOfEurope.zoomLevel = zoomMap.zoomLevel * 0.95;
                        }
                    }
                }

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
