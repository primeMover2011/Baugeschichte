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

    LineInput {
        id: searchInput
        width: parent.width
        hint: qsTr("Suchbegriff...")
        focus: true //flipBar.opened
        onAccepted: {
            searchModel.phrase = "";
            searchModel.phrase = text + "*";
        }
    }

    ListView {
        id: searchResult
        model: searchModel.model
        interactive: true
        clip: true
        anchors  {
            top: searchInput.bottom
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

                uiStack.push({item: Qt.resolvedUrl("RouteMap.qml"), properties: {searchFor: searchString}})
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        width: parent.width
        visible: searchModel.error !== ""

        text: searchModel.error
        color: "red"
        wrapMode: Text.Wrap
    }
}

