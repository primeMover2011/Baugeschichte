import QtQuick 2.4
import QtQuick.Controls 1.4
import "./"

BaseView {
    loading: searchModel.isLoading

    JsonModel {
        id: searchModel
        onNewobject: {
            for (var key in magneto.query.categorymembers) {
                var jsonObject = magneto.query.categorymembers[key];
                model.append(jsonObject);
            }
        }
        searchString: "http://baugeschichte.at/api.php?action=query&format=json&list=categorymembers&cmtitle=Category:Liste_(Routen)&cmsort=timestamp&cmdir=desc&cmlimit=50"
        Component.onCompleted: phrase = " " //fires a searchrequest

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
                hint: qsTr("Suchbegriff...")
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
        clip: true
        anchors  {
            top: theFocusScope.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

        }

        delegate: SearchResultDelegate {
            text: title
            onSelected:
            {
                var searchString=wot.replace(new RegExp(' ', 'g'),"_")//Manchmal müssen Spaces umgewandelt werden...
                //und um alle vorkommnisse von " " zu erstetzen muss man in Javascript eine RegEx verwenden.
                //http://stackoverflow.com/questions/1144783/replacing-all-occurrences-of-a-string-in-javascript
                //uiStack.push({item: Qt.resolvedUrl("SimpleMap.qml"), properties: {searchFor: searchString/*textitem.text*/}})
                uiStack.push({item: Qt.resolvedUrl("RouteMap.qml"), properties: {searchFor: searchString/*textitem.text*/}})
            }
        }
    }
}

