import QtQuick 2.4

Item {
    id: root
    width: parent.width
    height: textitem.height * 2.2

    property alias text: textitem.text
    signal selected(string wot)

    Rectangle {
        anchors.fill: parent
        color: "#d6d6d6"
        visible: mouse.pressed
    }

    Text {
        id: textitem
        color: "white"
        font.pixelSize: localHelper.largeFontSize
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
        }
    }

    DensityHelpers {
        id: localHelper
    }
}
