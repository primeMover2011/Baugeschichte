import QtQuick 2.4

Item {
    id: root

    property alias source: icon.source

    signal clicked(var mouse)

    width: localHelper.dp(50)
    height: localHelper.dp(50)

    opacity: enabled ? 1 : 0.3

    Image {
        id: icon
        anchors.fill: parent
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(mouse);
        }
    }
}
