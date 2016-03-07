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

    onClosing: {
        close.accepted = false;
    }

    Settings {
        id: settings
        property alias lastSeenLat: mapOfEurope.center.latitude
        property alias lastSeenLon: mapOfEurope.center.longitude


    }


    visible: true
    //    PositionSource
    property variant locationGraz: QtPositioning.coordinate(47.0666667, 15.45)
    Component.onCompleted: {
        dialog.getAllPois();

    }
    ExclusiveGroup {
        id: categoryGroup
    }
    width: 1024
    height: 800




    function selectCategory(theCat)
    {
       filteredTrailModel.setFilterWildcard(theCat);
    }
    menuBar: MenuBar {
        id: mainMenuBar
        Menu{
            id: categoryMenu
            title: "Categories"
            function createMenu()
            {
                clear()
                addCategory("Keine Kategorie");
                for (var i=0; i<categoryModel.count;i++) {
                    var catName = categoryModel.get(i).category
//                    var catName = categoryModel[i].category

                    addCategory(catName)
                }
            }

            function selectCategory(theCat)
            {
//                filteredTrailModel.setFilterWildcard("Geschichte");
                  if (theCat.indexOf("Keine") > -1)
                      theCat=""
                  filteredTrailModel.setFilterWildcard(theCat);
            }
            function addCategory(theName)
            {
                var item = addItem(theName)
                item.checkable = true;
                item.exclusiveGroup = categoryGroup;
                //console.log(theName);
                item.triggered.connect(function(){selectCategory(theName)});
            }


        }

/*        function createProviderMenuItem(provider)
        {
            var item = addItem(provider);
            item.checkable = true;
            item.triggered.connect(function(){selectProvider(provider)})
        }
*/
    }

/*    Connections {
        target: mapOfEurope
        onSelectedPoiChanged: {
            console.log("Poi:", mapOfEurope.selectedPoi)
        }

    }
    */
    ListModel {
        id: categoryModel
        Component.onCompleted: {
            var leCategories = '[{"category":"Ab 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Ab 2000 restauriert","color":"#ff0000"},{"category":"Aktuell (Graz)","color":"#ff0099"},{"category":"Aktuell (Salzburg)","color":"#ff0000"},{"category":"Bis 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Gedenkst\u00e4tten","color":"#ff0000"},{"category":"Geschichte","color":"#ff0000"},{"category":"Historische Ansicht vorhanden","color":"#ff0000"},{"category":"Leerstand","color":"#ff0000"},{"category":"Stadttore","color":"#ff0000"},{"category":"Gef\u00e4hrdet","color":"#ff0000"}]';


            var jsonCats = JSON.parse(leCategories);
            if (jsonCats.errors !== undefined)
                console.log("Error fetching searchresults: " + jsonCats.errors[0].message)
            else {

            for (var key in jsonCats) {

                var jsonObject = jsonCats[key];
                jsonObject.selected = false;
                categoryModel.append(jsonObject);
            }
            }

            categoryMenu.createMenu();
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
        focus: true
        z: 40000
        Keys.onReleased: {
            console.log("Keys.onrelease")
            console.log("uiStack Depth:" + uiStack.depth)
            if (event.key === Qt.Key_Back) {
                event.accepted = true;
                    if (uiStack.depth > 1) {
                        console.log("pop");
                        uiStack.pop();
                    }
                    else{
                        shutDownDialog.visible = true;
                    }
                }


        }

        StackView
        {
            id: uiStack
            initialItem: mapOfEurope
            onDepthChanged: {
                console.log("Depth changed:" + depth)
            }
            z:35000



            objectName: "theStackView"
            anchors.fill: parent
            MapComponent {
                id: mapOfEurope
                anchors.centerIn: parent;
                anchors.fill: parent
                center: locationGraz
                z:32000
                onSelectedPoiChanged: {
                    console.log("SelectedPoiChanged Begin")
                    uiStack.push({item: Qt.resolvedUrl("DetailsView.qml"), properties: {searchFor:selectedPoi}})
                    //console.log("SelectedPoiChanged End")
                }
                onSearch: {
                    uiStack.push({item: Qt.resolvedUrl("SearchPage.qml"), properties: {searchFor:selectedPoi}})
                }
                onRoutes:
                    uiStack.push({item: Qt.resolvedUrl("RouteView.qml")})

            }

/*            RgbPage {
            id: rgbComponent
            //opacity: 0.5
            onSearch: {
                uiStack.push({item: Qt.resolvedUrl("DetailsView.qml"), properties: {searchFor:"Burggasse 15"}})
            }

            }*/

        }

    }
    //Rectangle


}
