import QtQuick 2.4
import QtPositioning 5.5
import QtLocation 5.4

BaseView {
    property string searchFor:""
    property bool followMeActive: false
    onSearchForChanged: simpleMapSearchModel.phrase = searchFor//" "

    loading: simpleMapSearchModel.isLoading

    JsonModel {
        id: simpleMapSearchModel
        shouldEncode: false //due to searchapi problems when encoding routes...
        onNewobject: {
            routeMap.clearMapItems();
            routeMap.routeLine = Qt.createQmlObject("import QtLocation 5.4; MapPolyline {}", routeMap);
            routeMap.routeLine.line.width = 3;
            routeMap.routeLine.line.color = "green";
            routeMap.addMapItem(routeMap.routeLine);

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

                routeMap.routeLine.addCoordinate(QtPositioning.coordinate(jsonObject.lat, jsonObject.lon));
            }

            routeMap.fitViewportToMapItems()
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
        id:routeMap
        anchors.fill: parent
        center: locationGraz
        autoUpdatePois: false
        currentModel: simpleMapSearchModel.model
        onSelectedPoiChanged: {
            console.log("SelectedPoiChanged Begin")
            if (selectedPoi === "")
                return
            uiStack.push({
                             item: Qt.resolvedUrl(
                                       "DetailsView.qml"),
                             properties: {
                                 searchFor: selectedPoi
                             }
                         })
            //console.log("SelectedPoiChanged End")
            selectedPoi = ""
        }
        followMe: followMeActive

        property MapPolyline routeLine
    }
}
