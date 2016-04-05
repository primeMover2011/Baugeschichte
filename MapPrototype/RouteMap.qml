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
            var iCnt=0
            for (var key in magneto.payload) {
                var jsonObject = magneto.payload[key]
                if (jsonObject.lat === 0) continue;
                if (jsonObject.lon === 0) continue;
                iCnt++;
                jsonObject.coord={ "latitude":jsonObject.lat, "longitude": jsonObject.lon}

                model.append(jsonObject)

                routeLine.addCoordinate(QtPositioning.coordinate(jsonObject.lat, jsonObject.lon));
            }
            // viewportTimer.restart()
            //routeMap.currentModel = model
            var entryInTheMiddle = model.get(iCnt % 2)
            routeMap.center = QtPositioning.coordinate(entryInTheMiddle.coord.latitude,entryInTheMiddle.coord.longitude)
            //routeMap.fitViewportToMapItems()
        }
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getRoutePoints&name="

        onIsLoadingChanged: {
            if (isLoading) {
                routeLine.clear();
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

        MapPolyline {
            id: routeLine
            line.width: 3
            line.color: "green"

            function clear() {
                while (pathLength() > 0) {
                    removeCoordinate(0);
                }
            }
        }
    }
}
