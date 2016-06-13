import QtQuick 2.4
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtLocation 5.6
import QtPositioning 5.6
import "./Helper.js" as Helper
import "./"
import Baugeschichte 1.0

Map {
    id: root

    signal search
    signal categories
    signal routes

    property bool followMe:false
    property bool autoUpdatePois: true
    property variant currentModel: locationFilter
    property variant scaleLengths: [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000]
    property alias theItemModel: housetrailMapItems
    property double radius: 100

    property string selectedPoi: ""
    property int currentID: -1
    onCurrentIDChanged: {
        if (currentID < 0) {
            selectedPoi = "";
            if (markerLabel) {
                markerLabel.destroy();
            }
        }
    }

    property bool loading: false

    property MarkerLabel markerLabel

    readonly property int markerSize: localHelper.dp(50)
    readonly property real defaultZoomLevel: 16

    center: QtPositioning.coordinate(47.0666667, 15.45)

    zoomLevel: defaultZoomLevel

    onCenterChanged: {
        if (autoUpdatePois) {
            markerLoader.setLocation(center.latitude, center.longitude);
        }
    }

    onZoomLevelChanged: {
        updateRadius();
    }

    onWidthChanged: {
        updateRadius();
    }

    onHeightChanged: {
        updateRadius();
    }

    function updateRadius() {
        root.calculateScale();
        if (autoUpdatePois) {
            var coord1 = root.toCoordinate(Qt.point(0, 0))
            var coord2 = root.toCoordinate(Qt.point(root.width-1, root.height-1))
            var dist1 = Math.abs(coord1.latitude - coord2.latitude)
            var dist2 = Math.abs(coord1.longitude - coord2.longitude)
            var dist = (dist1 > dist2) ? dist1 : dist2;
            var radius = dist / 2.0;

            markerLoader.radius = radius;
            root.radius = root.center.distanceTo(coord1);

            markerLoader.loadAll = root.zoomLevel > 17;

            if (root.zoomLevel < 18) {
                var coord3 = root.toCoordinate(Qt.point(root.markerSize, 0))
                var markerDist = coord1.distanceTo(coord3)
                locationFilter.minDistance = markerDist;
            } else {
                locationFilter.minDistance = 1e-3
            }
        }
    }

    function calculateScale() {
        var coord1, coord2, dist, text, f
        f = 0
        coord1 = root.toCoordinate(Qt.point(0, scale.y))
        coord2 = root.toCoordinate(
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

    function resetToMainModel()
    {
        root.currentModel = locationFilter;
    }

    HouseLocationFilter {
        id: locationFilter
        sourceModel: filteredTrailModel
        location: root.center
        radius: root.radius
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: {
            root.currentID = -1;
        }
    }

    Slider {
        id: zoomSlider
        z: root.z + 3
        minimumValue: root.minimumZoomLevel
        maximumValue: root.maximumZoomLevel
        anchors.margins: 10
        anchors.bottom: scale.top
        anchors.top: parent.top
        anchors.right: parent.right
        orientation: Qt.Vertical
        value: root.zoomLevel
        onValueChanged: {
            root.zoomLevel = value
            //console.log("Zoomlevel: " + mapOfEurope.zoomLevel)
        }
    }

    Item {
        id: scale
        z: root.z + 3
        visible: scaleText.text != "0 m"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        height: scaleText.height * 2
        width: scaleImage.width

        Image {
            id: scaleImageLeft
            source: "resources/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImage.left
        }
        Image {
            id: scaleImage
            source: "resources/scale.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImageRight.left
        }
        Image {
            id: scaleImageRight
            source: "resources/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
        Label {
            id: scaleText
            color: "#004EAE"
            anchors.centerIn: parent
            text: "0 m"
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
            root.center = myPosition.position.coordinate
            //mapOfEurope.zoomLevel = 12
        }
        onActiveChanged:
        {
            console.log("open the pod bay doors, hal")
        }
    }

    plugin: initPlugin()
    function initPlugin() {
        return appCore.mapProvider === "osm" ? osmPlugin : mapBoxPlugin;
    }
    Plugin {
        id: osmPlugin
        name: "osm"
    }
    Plugin {
        id: mapBoxPlugin
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

    MapItemView {
        id: housetrailMapItems
        model: currentModel //houseTrailModel

        onModelChanged:{
            console.log("model changed")
        }

        delegate: MapQuickItem {
            id: mqItem
            coordinate: QtPositioning.coordinate(coord.latitude,
                                                 coord.longitude)

            anchorPoint.x: image.width * 0.5
            anchorPoint.y: image.height

            sourceItem: Item {
                id: theSourceItem
                width: image.width
                height: image.height

                Image {
                    id: image
                    antialiasing: true
                    source: dbId == root.currentID ? "resources/marker-2-blue.svg" : "resources/marker-2.svg"
                    width: root.markerSize
                    height: root.markerSize
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    anchors.fill: image
                    onPressed: changeCurrentItem()

                    function changeCurrentItem() {
                        console.log("changing!!")

                        if (root.markerLabel) {
                            root.markerLabel.destroy();
                        }

                        var component = Qt.createComponent("MarkerLabel.qml");
                        root.markerLabel = component.createObject(root);
                        root.markerLabel.mapItem = root;
                        root.addMapItem(root.markerLabel);

                        root.markerLabel.coordinate = mqItem.coordinate
                        root.markerLabel.z = 9999;
                        root.markerLabel.id = dbId;
                        root.markerLabel.title = title
                        root.markerLabel.visible = true;
                        root.currentID = dbId;
                    }
                }
            }
        }
    }

    MapQuickItem {
        id: myPositionCircle
        visible: myPosition.active
        coordinate: myPosition.position.coordinate
        anchorPoint.x: mePositron.width / 2
        anchorPoint.y: mePositron.height / 2


        sourceItem: Rectangle {
            id: mePositron
            color: "#00a200"
            border.color: "#190a33"
            border.width: 2
            smooth: true
            opacity: 0.5
            width: localHelper.dp(90)
            height: width
            radius: width/2

            SequentialAnimation on width {
                loops: Animation.Infinite
                NumberAnimation {
                    from: mePositron.width
                    to: mePositron.width * 1.8
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    from: mePositron.width * 1.8
                    to: mePositron.width
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
        }//<--MapCircle
    }

    Component.onCompleted: {
        root.updateRadius();
        zoomLevel = defaultZoomLevel;
    }
}
