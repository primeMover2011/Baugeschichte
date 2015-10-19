import QtQuick 2.4
import QtQuick.Window 2.2
import QtPositioning 5.5
import QtLocation 5.5

Window {
    visible: true
//    PositionSource
    property variant locationGraz: QtPositioning.coordinate(47.0666667, 15.45)
    Component.onCompleted: {
        dialog.getAllPois();
    }
    Map {
        id: mapOfEurope
        anchors.centerIn: parent;
        anchors.fill: parent
        plugin: Plugin {
            name: "mapbox"
            PluginParameter { name: "mapbox.map_id"; value: "primemover.c5fe94e8" }
            PluginParameter { name: "mapbox.access_token"; value: "pk.eyJ1IjoicHJpbWVtb3ZlciIsImEiOiIzNjFlYWNjZmZhMjAyNGFhMWQ0NDM0ZDIyMTE4YmEyMCJ9.d5wi3uI5VayKiniPnkxojg" }


        }
        center: locationGraz

        MapItemView {
            model: houseTrailModel
            delegate: MapQuickItem {
                coordinate   : QtPositioning.coordinate(coord.latitude, coord.longitude)
                anchorPoint.x: image.width * 0.5
                anchorPoint.y: image.height

                sourceItem: Image {
                    id: image
                    source: "marker.png"
                }
            }

        }
        /*==Mapitemview==*/
        MouseArea {
            //workaround for QTBUG-46388
            anchors.fill: parent
        }

    }
}
