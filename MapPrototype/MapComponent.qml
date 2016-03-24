import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtLocation 5.5
import QtPositioning 5.5
import "./Helper.js" as Helper
import "./"

Map {
    id: mapOfEurope
    signal search
    signal categories
    signal routes
    property bool followMe:false
    property variant scaleLengths: [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000]
    z: 20000
    zoomLevel: 16

    Timer {
        id: scaleTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            mapOfEurope.calculateScale()
        }
    }

    onCenterChanged: {
        scaleTimer.restart()
        //   if (mapOfEurope.followme)
        //if (mapOfEurope.center !== positionSource.position.coordinate) mapOfEurope.followme = false
    }

    onZoomLevelChanged: {
        scaleTimer.restart()
        //   if (mapOfEurope.followme) mapOfEurope.center = positionSource.position.coordinate
    }

    onWidthChanged: {
        scaleTimer.restart()
    }

    onHeightChanged: {
        scaleTimer.restart()
    }

    Slider {
        id: zoomSlider
        z: mapOfEurope.z + 3
        minimumValue: mapOfEurope.minimumZoomLevel
        maximumValue: mapOfEurope.maximumZoomLevel
        anchors.margins: 10
        anchors.bottom: scale.top
        anchors.top: parent.top
        anchors.right: parent.right
        orientation: Qt.Vertical
        value: mapOfEurope.zoomLevel
        onValueChanged: {
            mapOfEurope.zoomLevel = value
            //console.log("Zoomlevel: " + mapOfEurope.zoomLevel)
        }
    }

    function calculateScale() {
        var coord1, coord2, dist, text, f
        f = 0
        coord1 = mapOfEurope.toCoordinate(Qt.point(0, scale.y))
        coord2 = mapOfEurope.toCoordinate(
                    Qt.point(0 + scaleImage.sourceSize.width, scale.y))
        dist = Math.round(coord1.distanceTo(coord2))

        if (dist === 0) {

            // not visible
        } else {
            for (var i = 0; i < scaleLengths.length - 1; i++) {
                if (dist < (scaleLengths[i] + scaleLengths[i + 1]) / 2) {
                    f = scaleLengths[i] / dist
                    dist = scaleLengths[i]
                    break
                }
            }
            if (f === 0) {
                f = dist / scaleLengths[i]
                dist = scaleLengths[i]
            }
        }

        text = Helper.formatDistance(dist)
        scaleImage.width = (scaleImage.sourceSize.width * f) - 2 * scaleImageLeft.sourceSize.width
        scaleText.text = text
    }

    Item {
        id: scale
        z: mapOfEurope.z + 3
        visible: scaleText.text != "0 m"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        height: scaleText.height * 2
        width: scaleImage.width

        Image {
            id: scaleImageLeft
            source: "../resources/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImage.left
        }
        Image {
            id: scaleImage
            source: "../resources/scale.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImageRight.left
        }
        Image {
            id: scaleImageRight
            source: "../resources/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
        Label {
            id: scaleText
            color: "#004EAE"
            anchors.centerIn: parent
            text: "0 m"
        }
        Component.onCompleted: {
            mapOfEurope.calculateScale()
        }
    }

    DensityHelpers {
        id: localHelper
    }

    PositionSource {
        id: myPosition
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        //active: followMeSwitch.isRunning
        active: followMe
        updateInterval: 1500
        onPositionChanged: {
            mapOfEurope.center = myPosition.position.coordinate
            //mapOfEurope.zoomLevel = 12
        }
        onActiveChanged:
        {
            console.log("open the pod bay doors, hal")
        }
    }

    plugin: Plugin {
        name: "mapbox"
        PluginParameter {
            name: "mapbox.map_id"
            value: "primemover.c5fe94e8"
        }
        PluginParameter {
            name: "mapbox.access_token"
            value: "pk.eyJ1IjoicHJpbWVtb3ZlciIsImEiOiIzNjFlYWNjZmZhMjAyNGFhMWQ0NDM0ZDIyMTE4YmEyMCJ9.d5wi3uI5VayKiniPnkxojg"
        }
    }
    center: QtPositioning.coordinate(47.0666667, 15.45)
    property string selectedPoi: ""

    MapItemView {
        id: housetrailMapItems
        model: filteredTrailModel //houseTrailModel
        property Item currentItem

        //z: 29000

        //onCurrentItemChanged:
        delegate: MapQuickItem {
            id: mqItem
            coordinate: QtPositioning.coordinate(coord.latitude,
                                                 coord.longitude)
            anchorPoint.x: image.width * 0.5
            anchorPoint.y: image.height
            z: 5

            sourceItem: Item {
                id: theSourceItem
                //property Item myBubble : bubble
                z: 10000

                Rectangle {

                    id: bubble
                    color: "#cccccc"
                    border.width: 1
                    width: textItem.width * 1.2
                    height: textItem.height * 1.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 3
                    z: 10

                    onZChanged: console.log("z:" + z)
                    visible: false
                    Text {
                        id: textItem
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: title
                        font.pixelSize: localHelper.sp(24)
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: selectPoi(title)
                        onClicked: selectPoi(title)
                        function selectPoi(aTitle) {
                            mapOfEurope.selectedPoi = aTitle
                            bubble.visible = false
                        }
                    }
                }

                Image {
                    id: image
                    antialiasing: true
                    source: "resources/marker-2.svg"
                    width: localHelper.sp(50)
                    height: localHelper.sp(50)
                    fillMode: Image.PreserveAspectFit
                    z: 9
                    onZChanged: console.log("z:" + z)

                    MouseArea {
                        anchors.fill: parent
                        z: 4
                        onPressed: changeCurrentItem()
                        onClicked: changeCurrentItem()

                        function changeCurrentItem() {
                            console.log("changing!!")
                            tricksterRectangle.coordinate = mqItem.coordinate
                            tricksterRectangle.title = title
                            tricksterRectangle.visible = true
                        }
                    }
                }
            }
        }
    }
    MapCircle {
        id: point
        visible: myPosition.active
        radius: 100
        color: "blue" //#46a2da"
        border.color: "#190a33"
        border.width: 2
        smooth: true
        opacity: 0.4

        center: myPosition.position.coordinate

        SequentialAnimation on radius {
            loops: Animation.Infinite
            NumberAnimation {
                from: point.radius
                to: point.radius * 1.8
                duration: 800
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                from: point.radius * 1.8
                to: point.radius
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
        /* SequentialAnimation on height {
                            loops: Animation.Infinite
                                                NumberAnimation { from: height * 1; to: height * 1.15; duration: 1200; easing.type: Easing.InOutQuad }
                                                                    NumberAnimation { from: height * 1.15; to: height * 1; duration: 1000; easing.type: Easing.InOutQuad }
                                                                                    }
                                                                                    */
    }

    MapQuickItem {
        id: tricksterRectangle
        zoomLevel: 0.0
        //coordinate: mqItem.coordinate
        onCoordinateChanged: {
            console.log("coordinate changed")
        }
        property string title: "NO Title"
        onTitleChanged: {
            textItem2.text = title
        }

        z: 20
        anchorPoint.x: coco.width / 2
        anchorPoint.y: coco.height * 1.9

        sourceItem: Rectangle {
            id: coco

            color: "#ffffff"

            border.width: 1
            border.color: "#e02222"
            width: textItem2.width * 1.2
            height: textItem2.height * 1.5
            //x: width/2
            //y: height/2
            //anchors.horizontalCenter: tricksterRectangle.horizontalCenter
            //anchors.verticalCenter: tricksterRectangle.verticalCenter

            //anchors.horizontalCenter: parent.horizontalCenter
            //anchors.verticalCenter: parent.verticalCenter
            radius: 3

            //z: 10
            onZChanged: console.log("z:" + z)
            visible: true
            Text {
                id: textItem2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "Text"
                font.pixelSize: localHelper.sp(24)
                color: "#ff0000"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onPressed: selectPoi(tricksterRectangle.title)
                onClicked: selectPoi(tricksterRectangle.title)
                function selectPoi(aTitle) {
                    mapOfEurope.selectedPoi = aTitle
                    tricksterRectangle.visible = false
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

/*
    RowLayout {
        //        Layout.fillWidth: true
        z: 10
        anchors {
            left: parent.left
            right: parent.right
            margins: 5
        }
        id: myLayout
        property real sideLength: localHelper.dp(60)
        height: 60

/*        Rectangle {
            id: cellLeft
            color: "#444444"
            height: myLayout.sideLength
            Layout.preferredWidth: myLayout.sideLength
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
        }SEARCH*/

        /*Rectangle {
            id: cellMiddle
            color: "#444444"
            Layout.preferredWidth: myLayout.sideLength
            height: myLayout.sideLength
            Layout.alignment: Qt.AlignHCenter
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("cellMiddle clicked")
                    routes()
                }
            }
        }ROUTES*/
  /*      Rectangle {
            id: followMeSwitch

            property bool isRunning: false
            visible: myPosition.valid

            color: "#0000ff"
            Layout.preferredWidth: myLayout.sideLength
            opacity: isRunning ? 1 : 0.5
            height: myLayout.sideLength
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
*/

}//***RowLayout

