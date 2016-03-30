import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtLocation 5.5
import QtPositioning 5.5
import "./"

Map {
    id: mapOfRoute
    signal followMe
    zoomLevel: 13
    property string searchFor: ""
    onSearchForChanged: simpleMapSearchModel.phrase = searchFor//" "
    onZoomLevelChanged: console.log("MapofRoute zoomlevel:" + zoomLevel)

    Timer {
        id: viewportTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            mapOfRoute.fitViewportToMapItems()
        }
    }


    JsonModel {
        id: simpleMapSearchModel
        shouldEncode: false //due to searchapi problems when encoding routes...
        onNewobject: {
            for (var key in magneto.payload) {
                var jsonObject = magneto.payload[key]
                if (jsonObject.lat === 0) continue;
                if (jsonObject.lon === 0) continue;

                model.append(jsonObject)
            }
           // viewportTimer.restart()
        }
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getRoutePoints&name="
    }
//QtPositioning.coordinate(-27.5, 153.1)
    MapPolyline {
        id: theRoute

    }

    DensityHelpers {
        id: localHelper
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

    PositionSource {
        id: myPosition
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        active: false//followMeSwitch.isRunning
        updateInterval: 1500
        onPositionChanged: {
            mapOfRoute.center = myPosition.position.coordinate

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
        model: simpleMapSearchModel.model //houseTrailModel
        property Item currentItem
        //autoFitViewport: true

        delegate: MapQuickItem {
            id: mqItem
            coordinate: QtPositioning.coordinate(lat,
                                                 lon)
            anchorPoint.x: image.width * 0.5
            anchorPoint.y: image.height

            sourceItem: Item {
                id: theSourceItem
                property Item myBubble: bubble
                Image {
                    id: image
                    source: "marker.png"
                    width: localHelper.sp(50)
                    height: localHelper.sp(50)
                    fillMode: Image.PreserveAspectFit
                    z: 2

                    MouseArea {
                        anchors.fill: parent
                        z: 4
                        onPressed: {
                            if (housetrailMapItems.currentItem)
                                housetrailMapItems.currentItem.myBubble.visible = false
                            bubble.visible = true
                            housetrailMapItems.currentItem = theSourceItem
                        }
                    }
                }

                Rectangle {
                    id: bubble
                    color: "lightblue"
                    border.width: 1
                    width: textItem.width * 1.5
                    height: textItem.height * 2
                    radius: 5
                    z: 3
                    visible: false
                    Text {
                        id: textItem
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: title
                        font.pixelSize: localHelper.sp(12)
                    }
                    MouseArea {
                        anchors.fill: parent
                        z: 5
                        preventStealing: true

                        onPressed: {
                            mapOfEurope.selectedPoi = title
                            bubble.visible = false
                            uiStack.push({
                                             item: Qt.resolvedUrl(
                                                       "DetailsView.qml"),
                                             properties: {
                                                 searchFor: textItem.text
                                             }
                                         })
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
    BusyIndicator {
        running: simpleMapSearchModel.isLoading
        onRunningChanged: console.log("running? "+running)

    }

    //***RowLayout
}
