import QtQuick 2.4
import QtQuick.Controls 1.4
import "./"

BaseView {

    ListModel {
        id: categoryModel
        Component.onCompleted: {
            var leCategories = '[{"category":"Keine Kategorie","color":"#ff0000"},{"category":"Ab 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Ab 2000 restauriert","color":"#ff0000"},{"category":"Aktuell (Graz)","color":"#ff0099"},{"category":"Aktuell (Salzburg)","color":"#ff0000"},{"category":"Bis 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Gedenkst\u00e4tten","color":"#ff0000"},{"category":"Geschichte","color":"#ff0000"},{"category":"Historische Ansicht vorhanden","color":"#ff0000"},{"category":"Leerstand","color":"#ff0000"},{"category":"Stadttore","color":"#ff0000"},{"category":"Gef\u00e4hrdet","color":"#ff0000"}]'

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
        }
    }



    DensityHelpers {
        id:localHelper
    }

    FocusScope {
        id: theFocusScope
        signal ok
        height: localHelper.dp(60)
        width: parent.width
        Rectangle {
            anchors.fill: parent
            color: "#999999"

            Rectangle { color: "#c1c1c1"; width: parent.width; height: 1 }
            Rectangle { color: "#707070"; width: parent.width; height: 1; anchors.bottom: parent.bottom }

            LineInput {
                id: lineInput
                hint: qsTr("Adresse...")
                focus: true //flipBar.opened
                anchors { fill: parent; margins: 6 }
                onAccepted: {
                    if (Qt.inputMethod.visible)
                        Qt.inputMethod.hide()
                    console.log("accepted")
//                    searchModel.phrase = text + "*"
                }
            }
        //lineInput


        }
    }//focusscope

    ListView {
        id: searchResult
        model: categoryModel
        interactive: true
        anchors  {
            top: theFocusScope.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

        }

        delegate: SearchResultDelegate {
                text: category
                onSelected: {
                    selectCategory(category)
                    uiStack.pop()
                }

                function selectCategory(theCat) {
                    //                filteredTrailModel.setFilterWildcard("Geschichte");
                    if (theCat.indexOf("Keine") > -1)
                        theCat = ""
                    filteredTrailModel.setFilterWildcard(theCat)
                }
            }

    }


}

