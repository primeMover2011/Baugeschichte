import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtLocation 5.5
import QtPositioning 5.5

Map {
    id: mapOfEurope
    signal search
    signal categories
    signal followMe
    zoomLevel: 16

    MapCircle {
        id: point
        visible: true//myPosition.active
        radius: 100
        color: "blue" //#46a2da"
        border.color: "#190a33"
        border.width: 2
        smooth: true
        opacity: 0.4




        center: myPosition.position.coordinate


        SequentialAnimation on radius {
                   loops: Animation.Infinite
                   NumberAnimation { from: point.radius; to: point.radius * 1.8; duration: 800; easing.type: Easing.InOutQuad }
                   NumberAnimation { from: point.radius * 1.8 ; to: point.radius; duration: 1000; easing.type: Easing.InOutQuad }
               }
       /* SequentialAnimation on height {
                    loops: Animation.Infinite
                    NumberAnimation { from: height * 1; to: height * 1.15; duration: 1200; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: height * 1.15; to: height * 1; duration: 1000; easing.type: Easing.InOutQuad }
                }
*/
    }

    PositionSource {
        id: myPosition
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        active: followMeSwitch.isRunning
        updateInterval: 1500
        onPositionChanged: {
            mapOfEurope.center = myPosition.position.coordinate
            //mapOfEurope.zoomLevel = 12
        }




    }





    plugin: Plugin {
        name: "mapbox"
        PluginParameter { name: "mapbox.map_id"; value: "primemover.c5fe94e8" }
        PluginParameter { name: "mapbox.access_token"; value: "pk.eyJ1IjoicHJpbWVtb3ZlciIsImEiOiIzNjFlYWNjZmZhMjAyNGFhMWQ0NDM0ZDIyMTE4YmEyMCJ9.d5wi3uI5VayKiniPnkxojg" }
    }
    center: QtPositioning.coordinate(47.0666667, 15.45)
    property string selectedPoi: ""

    MapItemView {
        id: housetrailMapItems
        model: houseTrailModel
        delegate: MapQuickItem {
            coordinate   : QtPositioning.coordinate(coord.latitude, coord.longitude)
            anchorPoint.x: image.width * 0.5
            anchorPoint.y: image.height

            sourceItem: Item {

                Image {
                    id: image
                    source: "marker.png"
                    width: 100
                    height: 100
                    fillMode: Image.PreserveAspectFit



                    MouseArea {
                        anchors.fill: parent
                        z: 2
                        onPressed: {
                            bubble.visible = true
                        }

                    }
                }

                Rectangle {
                    id: bubble
                    color: "lightblue"
                    border.width: 1
                    width: text.width * 1.5
                    height: text.height * 2
                    radius: 5
                    z: 1
                    visible: false
                    Text {
                        id: text
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: title
                    }
                    MouseArea {
                        anchors.fill: parent
                        z: 1
                        preventStealing: true

                        onPressed: {
                            mapOfEurope.selectedPoi = title
                            bubble.visible = false
                        }
                    }
                }


            }

        }
    }

    /*==Mapitemview==*/
    MouseArea {
        //workaround for QTBUG-46388
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: {
//to prevent swallowing of events
            mouse.accepted = false
        }
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
        id: followMeSwitch

        property bool isRunning: false
        visible: myPosition.valid
        color: "#0000ff"
        Layout.preferredWidth: 50
        opacity: isRunning ? 1 : 0.5
        height: 50
        Layout.alignment: Qt.AlignRight
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("cellRight clicked")
                followMeSwitch.isRunning = !followMeSwitch.isRunning
                if (followMeSwitch === true)
                    followMe()
            }

        }

    }

    }
//***RowLayout



}
