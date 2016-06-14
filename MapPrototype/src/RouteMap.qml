import QtQuick 2.4
import QtPositioning 5.5
import QtLocation 5.4

BaseView {
    property string searchFor:""
    property bool followMeActive: false
    readonly property bool detailsOpen: details.visible
    readonly property bool splitScreen: width > height

    function closeDetails() {
        routeMap.selectedPoi = "";
    }

    onSearchForChanged: simpleMapSearchModel.phrase = searchFor//" "

    loading: simpleMapSearchModel.isLoading

    JsonModel {
        id: simpleMapSearchModel
        shouldEncode: false //due to searchapi problems when encoding routes...
        onNewobject: {
            routeMap.clearMapItems();

            for (var key in magneto.payload) {
                var jsonObject = magneto.payload[key]
                if (jsonObject.lat === 0) continue;
                if (jsonObject.lon === 0) continue;

                var modelObject = {
                    "dbId": jsonObject.id,
                    "title": jsonObject.title,
                    "coord": {"latitude":jsonObject.lat, "longitude": jsonObject.lon}
                }
                model.append(modelObject)
            }

            routeMap.routeLine = Qt.createQmlObject("import QtLocation 5.6; RouteLine {}", routeMap);
            routeMap.addMapItem(routeMap.routeLine);
            routeMap.routeLine.source = "http://baugeschichte.at/" + magneto.kml;
        }
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getRoutePoints&name="

        onIsLoadingChanged: {
            if (isLoading) {
                routeMap.clearMapItems();
            }
        }
    }

    DensityHelpers {
        id: localHelper
    }

    MapComponent {
        id: routeMap
        width: splitScreen ? details.x : parent.width
        height: parent.height

        center: locationGraz
        autoUpdatePois: false
        currentModel: simpleMapSearchModel.model

        visible: parent.splitScreen || !details.visible

        onSelectedPoiChanged: {
            console.log("SelectedPoiChanged Begin")
            details.searchFor = selectedPoi;
        }
        followMe: followMeActive

        property RouteLine routeLine
        Connections {
            target: routeMap.routeLine
            onLoadingChanged: {
                if (!loading) {
                    routeMap.fitViewportToMapItems();
                }
            }
        }
    }

    DetailsView {
        id: details

        x: visible ? (parent.splitScreen ? parent.width / 2 : 0) : parent.width
        width: parent.splitScreen ? parent.width / 2 : parent.width
        height: parent.height

        clip: true

        visible: searchFor != ""
    }
}