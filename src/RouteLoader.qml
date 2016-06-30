import QtQuick 2.4
import QtPositioning 5.5
import QtLocation 5.4

Item {
    id: root
    property string searchFor:""

    onSearchForChanged: simpleMapSearchModel.phrase = searchFor//" "

    readonly property alias loading: simpleMapSearchModel.isLoading

    property var routeHouses: []

    function isRouteHouse(title) {
        for (var i=0; i<routeHouses.length; ++i) {
            if (title === routeHouses[i].title) {
                return true;
            }
        }
        return false;
    }

    visible: false

    JsonModel {
        id: simpleMapSearchModel
        shouldEncode: false //due to searchapi problems when encoding routes...
        onNewobject: {
            root.routeHouses = [];
            var minLat = Number.MAX_VALUE;
            var maxLat = -Number.MAX_VALUE;
            var minLon = Number.MAX_VALUE;
            var maxLon = -Number.MAX_VALUE;

            for (var key in magneto.payload) {
                var jsonObject = magneto.payload[key]
                if (jsonObject.lat === 0) continue;
                if (jsonObject.lon === 0) continue;

                var modelObject = {
                    "dbId": jsonObject.id,
                    "title": jsonObject.title,
                    "coord": {"latitude":jsonObject.lat, "longitude": jsonObject.lon}
                }
                routeHouses.push(modelObject)

                minLat = Math.min(jsonObject.lat, minLat);
                maxLat = Math.max(jsonObject.lat, maxLat);
                minLon = Math.min(jsonObject.lon, minLon);
                maxLon = Math.max(jsonObject.lon, maxLon);

                var center = QtPositioning.coordinate((minLat + maxLat) / 2, (minLon + maxLon) / 2);
                appCore.currentMapPosition = center;
            }

            appCore.routeKML = magneto.kml;
        }
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getRoutePoints&name="

        onIsLoadingChanged: {
            if (isLoading) {
                root.routeHouses = [];
            }
        }
    }
}
