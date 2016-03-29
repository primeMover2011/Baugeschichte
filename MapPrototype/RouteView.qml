import QtQuick 2.0
import QtQuick.Controls 1.4
import "./"

Item {
    JsonModel {
        id: searchModel
        onNewobject: {
            for (var key in magneto.query.categorymembers) {
                var jsonObject = magneto.query.categorymembers[key];
                model.append(jsonObject);
            }
        }
        searchString: "http://baugeschichte.at/api.php?action=query&format=json&list=categorymembers&cmtitle=Category:Liste_(Routen)&cmsort=timestamp&cmdir=desc&cmlimit=50"
        onIsLoaded: {
            console.debug("Reload searchModel")

        }
        Component.onCompleted: phrase = " " //fires a searchrequest

    }
    DensityHelpers {
        id:localHelper
    }

    BusyIndicator {
        running: searchModel.isLoading === true
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
                hint: "Suchbegriff..."
                focus: true //flipBar.opened
                anchors { fill: parent; margins: 6 }
                onAccepted: {
                    if (Qt.inputMethod.visible)
                        Qt.inputMethod.hide()
                    console.log("accepted")
                    searchModel.phrase = text + "*"
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
                onSelected:
                {
                    var searchString=wot.replace(" ","_")//Manchmal müssen Spaces umgewandelt werden...
                    uiStack.push({item: Qt.resolvedUrl("SimpleMap.qml"), properties: {searchFor: searchString/*textitem.text*/}})
                }
            }

    }


}

