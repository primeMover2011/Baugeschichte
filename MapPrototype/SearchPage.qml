import QtQuick 2.0
import QtQuick.Controls 1.4
import "./"

Item {

/*    SearchModel {
        id: searchModel
        searchString: "http://baugeschichte.at/api.php?action=query&list=search&srwhat=text&format=json&srsearch="
        onIsLoaded: {
            console.debug("Reload searchModel")

        }
    }
 */
    JsonModel {
        id: searchModel
        onNewobject: {
            for (var key in magneto.query.search) {
                var jsonObject = magneto.query.search[key];
                model.append(jsonObject);
            }
        }
        searchString: "http://baugeschichte.at/api.php?action=query&list=search&srwhat=text&format=json&srsearch="
        onIsLoaded: {
            console.debug("Reload searchModel")

        }

    }

    FocusScope {
        id: theFocusScope
        signal ok
        height: 60
        width: parent.width
        Rectangle {
            anchors.fill: parent
            color: "#999999"

            Rectangle { color: "#c1c1c1"; width: parent.width; height: 1 }
            Rectangle { color: "#707070"; width: parent.width; height: 1; anchors.bottom: parent.bottom }

            LineInput {
                id: lineInput
                hint: "Was wollen?"
                focus: true //flipBar.opened
                anchors { fill: parent; margins: 6 }
                onAccepted: {
                    if (Qt.inputMethod.visible)
                        Qt.inputMethod.hide()
                    console.log("accepted")
                    searchModel.phrase = text
                }
            }
        //lineInput


        }
    }//focusscope

    ListView {
        id: searchResult
        model: searchModel.model
        interactive: true
        anchors  {
            top: theFocusScope.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

        }
 //        clip: true

        delegate: SearchResultDelegate {
                text: title
                //onClicked: stackView.push(Qt.resolvedUrl(page))

            }

    }


}

