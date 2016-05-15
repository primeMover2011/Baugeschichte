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

ApplicationWindow{
    id: root

    width: 1024
    height: 800

    visible: true

    readonly property bool loading: uiStack.currentItem.loading || dialog.loading

    property MapComponent mainMap: null

    onClosing: {
        close.accepted = false
    }
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

    toolBar: Item {
        id: theTool
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

            ToobalButton {
                id: mapButton
                source: "resources/Map-icon.svg"
                onClicked: {
                    filteredTrailModel.setFilterWildcard("");
                    mainMap.resetToMainModel();
                    mainMap.currentID = -1;
                    uiStack.pop(null);
                }
            }

            ToobalButton {
                id: searchButton
                source: "resources/System-search.svg"
                onClicked: {
                    mainMap.currentID = -1;
                    uiStack.pop(null);
                    uiStack.push({
                                     item: Qt.resolvedUrl("SearchPage.qml")
                                 })
                }
            }

            ToobalButton {
                id: categoriesButton
                source: "resources/Edit-find-cats.svg"
                onClicked: {
                    mainMap.currentID = -1;
                    uiStack.pop(null);
                    uiStack.push({
                                     item: Qt.resolvedUrl("CategoryselectionView.qml")
                                 })
                }
            }

            ToobalButton {
                id: theFollowMeButton
                source: "qrc:/resources/Ic_gps_" + (isActive ? "not_fixed" : "off") + "_48px.svg"
                enabled: thePosition.valid

                property bool isActive: false

                onClicked: {
                    isActive = !isActive;
                }
            }

            ToobalButton {
                id: routesButton
                source: "resources/Edit-check-sheet.svg"
                onClicked: {
                    mainMap.currentID = -1;
                    uiStack.push({
                                     item: Qt.resolvedUrl("RouteView.qml")
                                 })
                }
            }
        }

        Item {
            id: loadingIndicator
            width: height
            height: theTool.height

            anchors.right: parent.right
            anchors.top: parent.top

            BusyIndicator {
                anchors.fill: parent
                anchors.margins: theTool.height * 0.1

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
    Component.onCompleted: {
        //dialog.getAllPois();
    }

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

        focus: true
        Keys.onReleased: {
            console.log("Keys.onrelease")
            console.log("uiStack Depth:" + uiStack.depth)
            if (event.key === Qt.Key_Back) {
                event.accepted = true
                if (uiStack.currentItem.detailsOpen) {
                    uiStack.currentItem.closeDetails();
                } else {
                    if (uiStack.depth > 1) {
                        uiStack.pop()
                        loader_mapOfEurope.item.currentID = -1;
                    } else {
                        shutDownDialog.visible = true
                    }
                }
            }
        }
    }

    StackView {
        id: uiStack
        anchors.fill: parent
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

                function closeDetails() {
                    mapOfEurope.selectedPoi = "";
                }

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
                    }

                    center: locationGraz
                    onSelectedPoiChanged: {
                        console.log("SelectedPoiChanged Begin: "+selectedPoi)
                        details.searchFor = selectedPoi;
                    }

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

                    visible: searchFor != ""
                }
            }
        }
        Loader {
            id: loader_mapOfEurope
            sourceComponent: component_mapOfEurope
            readonly property bool loading: item ? item.loading : false
            readonly property bool detailsOpen: item ? item.detailsOpen : false

            function closeDetails() {
                if (item) {
                    item.closeDetails();
                }
            }
        }
    }
}
