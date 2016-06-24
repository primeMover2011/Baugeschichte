import QtQuick 2.4
import QtQuick.Controls 1.4
import "./"

BaseView {
    loading: searchModel.isLoading

    JsonModel {
        id: searchModel
        onNewobject: {
            for (var key in magneto.query.search) {
                var jsonObject = magneto.query.search[key];
                model.append(jsonObject);
            }
        }
        searchString: "http://baugeschichte.at/api.php?action=query&list=search&srwhat=text&format=json&srsearch="
    }

    LineInput {
        id: searchInput
        width: parent.width
        hint: qsTr("Adresse...")
        onAccepted: {
            searchModel.phrase = ""
            searchModel.phrase = text + "*"
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
            onSelected: {
                appCore.selectedHouse = title;
                appCore.showDetails = true;
                appCore.centerSelectedHouse();
                uiStack.pop(null);
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

