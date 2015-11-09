import QtQuick 2.0
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4

Item {
//        anchors.fill: parent
    id: firstPage
    signal search
    signal categories


    width: uiStack.width
    anchors.fill: parent

    onWidthChanged: {
        console.log("newWidth:", width)

    }

    //height: 200
    Component.onCompleted: {
        console.log("parentname:", parent.objectName)

    }

    RowLayout{
//        Layout.fillWidth: true
        anchors {
            left: parent.left
            right: parent.right
            margins: 5
        }

        height: 60




            Rectangle{
                id: cellLeft
                color: "#ff0000"
                height: 50
                Layout.preferredWidth: 50
                Layout.alignment: Qt.AlignLeft
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                      console.log("cellLeft clicked")
                      search()
                    }

                }
                Image {
                    source: "resources/icon-search.png"
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

    Rectangle{
        id: cellMiddle
        color: "#00ff00"
        Layout.preferredWidth: 50
        height: 50
        Layout.alignment: Qt.AlignHCenter
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("cellMiddle clicked")
              search()
            }

        }

    }
    Rectangle{
        id: cellRight
        color: "#0000ff"
        Layout.preferredWidth: 50
        height: 50
        Layout.alignment: Qt.AlignRight
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("cellRight clicked")
                categories()
            }

        }

    }

    }
    //RowLayOut


}

