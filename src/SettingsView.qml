import QtQuick 2.6
import QtQuick.Controls 1.4

Item {
    id: root

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#f8f8f8"
    }
    MouseArea {
        id: clickCatcher
    }

    Column {
        x: spacing
        y: spacing
        spacing: mapText.height / 4

        Text {
            id: mapText
            text: qsTr("Map provider")
        }
        ComboBox {
            width: mapText.width * 2
            model: ListModel {
                id: providerModel
                ListElement { text: qsTr("OpenStreetMap"); value: "osm" }
                ListElement { text: qsTr("MapBox"); value: "mapbox" }
            }
            currentIndex: appCore.mapProvider === "osm" ? 0 : 1
            onCurrentIndexChanged: {
                appCore.mapProvider = providerModel.get(currentIndex).value;
            }
        }
    }

    Component.onDestruction: {
        appCore.reloadUI();
    }
}
