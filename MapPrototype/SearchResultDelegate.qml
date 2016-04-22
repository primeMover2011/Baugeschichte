import QtQuick 2.4

Item {
    id: root
    width: parent.width
    height: 88

    property alias text: textitem.text
    signal selected(string wot)

    Rectangle {
        anchors.fill: parent
//        color: "#11ffffff"
        color: "#d6d6d6"
        visible: mouse.pressed
    }

    Text {
        id: textitem
        color: "white"
        font.pixelSize: 32
        text: modelData
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 30
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15
        height: 1
        color: "#424246"
    }

    Image {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        source: "resources/navigation_next_item.png"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {
            selected(textitem.text)
            //uiStack.push({item: Qt.resolvedUrl("DetailsView.qml"), properties: {searchFor:textitem.text}})
        }

    }
}
