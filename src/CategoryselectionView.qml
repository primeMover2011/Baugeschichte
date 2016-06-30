import QtQuick 2.4
import QtQuick.Controls 1.4
import "./"

BaseView {

    ListModel {
        id: categoryModel
        Component.onCompleted: {
            var leCategories = '[{"category":"Keine Kategorie","color":"#ff0000"},{"category":"Ab 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Ab 2000 restauriert","color":"#ff0000"},{"category":"Aktuell (Graz)","color":"#ff0099"},{"category":"Aktuell (Salzburg)","color":"#ff0000"},{"category":"Bis 2000 abgerissene Geb\u00e4ude","color":"#ff0000"},{"category":"Gedenkst\u00e4tten","color":"#ff0000"},{"category":"Geschichte","color":"#ff0000"},{"category":"Historische Ansicht vorhanden","color":"#ff0000"},{"category":"Leerstand","color":"#ff0000"},{"category":"Stadttore","color":"#ff0000"},{"category":"Gef\u00e4hrdet","color":"#ff0000"}]'

            var jsonCats = JSON.parse(leCategories)
            if (jsonCats.errors !== undefined) {
                console.log("Error fetching searchresults: " + jsonCats.errors[0].message)
            } else {
                for (var key in jsonCats) {
                    var jsonObject = jsonCats[key]
                    jsonObject.selected = false
                    categoryModel.append(jsonObject)
                }
            }
        }
    }

    LineInput {
        id: searchInput
        width: parent.width
//        hint: qsTr("Adresse...")
//        focus: true //flipBar.opened
        enabled: false
        hint: qsTr("No search yet...")
        onAccepted: {
//            searchModel.phrase = text + "*"
        }
    }

    ListView {
        id: searchResult
        model: categoryModel
        interactive: true
        anchors  {
            top: searchInput.bottom
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

