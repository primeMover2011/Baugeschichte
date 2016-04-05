import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtPositioning 5.5
import QtLocation 5.5
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import "./"

ApplicationWindow {

    width: 1024
    height: 800

    visible: true

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

    toolBar: Rectangle {
        id: theTool
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: 0.5
        height: localHelper.dp(50)

        RowLayout {
            anchors.fill: parent

            ToobalButton {
                id: mapButton
                source: "resources/Map-icon.svg"
                onClicked: {
                    while (uiStack.depth > 1) {
                        uiStack.pop()
                    }
                }
            }

            ToobalButton {
                id: searchButton
                source: "resources/System-search.svg"
                onClicked: {
                    if (uiStack.depth > 1) {
                        uiStack.clear()
                    }
                    uiStack.push({
                                     item: Qt.resolvedUrl("SearchPage.qml")
                                 })
                }
            }

            ToobalButton {
                id: categoriesButton
                source: "resources/Edit-find-cats.svg"
                onClicked: {
                    if (uiStack.depth > 1) {
                        uiStack.clear()
                    }
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
                    uiStack.push({
                                     item: Qt.resolvedUrl("RouteView.qml")
                                 })
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
        title: "Baugeschichte App beenden?"
        onButtonClicked: console.log("clicked button " + clickedButton)
        onYes: Qt.quit()
        onNo: visible = false
    }

    Rectangle {
        color: "#060606"
        anchors.fill: parent
        //anchors.topMargin: toolBar.height
//        anchors { right: parent.right; left:parent.left;
//            top: toolBar.bottom; bottom: parent.bottom; /*margins: 10*/ }

        focus: true
        z: 40000
        Keys.onReleased: {
            console.log("Keys.onrelease")
            console.log("uiStack Depth:" + uiStack.depth)
            if (event.key === Qt.Key_Back) {
                event.accepted = true
                if (uiStack.depth > 1) {
                    console.log("pop")
                    uiStack.pop()
                    loader_mapOfEurope.item.selectedPoi = ""
                    //mapOfEurope.selectedPoi = ""
                } else {
                    shutDownDialog.visible = true
                }
            }
        }
        StackView {
            id: uiStack
            initialItem: loader_mapOfEurope
            onDepthChanged: {
                console.log("Depth changed:" + depth)
            }
            z: 35000

            objectName: "theStackView"
            anchors.fill: parent


            Component {
                id: component_mapOfEurope

                MapComponent {
                    id: mapOfEurope
                    Settings {
                        id: settings
                        property alias lastSeenLat: mapOfEurope.center.latitude
                        property alias lastSeenLon: mapOfEurope.center.longitude
                    }

                    center: locationGraz
                    z: 32000
                    onSelectedPoiChanged: {
                        console.log("SelectedPoiChanged Begin")
                        if (selectedPoi === "")
                            return
                        uiStack.push({
                                         item: Qt.resolvedUrl(
                                                   "DetailsView.qml"),
                                         properties: {
                                             searchFor: selectedPoi
                                         }
                                     })
                        //console.log("SelectedPoiChanged End")
                        selectedPoi = ""
                    }
                    followMe: theFollowMeButton.isActive
                }
            }
            Loader {
                id: loader_mapOfEurope

                sourceComponent: component_mapOfEurope
                anchors.centerIn: parent
                anchors.fill: parent
            }

        }
    }
    //Rectangle
}
