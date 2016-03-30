import QtQuick 2.0
import QtPositioning 5.5

Item {
    property string searchFor:""
    property bool followMeActive: false
    onSearchForChanged: simpleMapSearchModel.phrase = searchFor//" "

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
                }
                // viewportTimer.restart()
                //routeMap.currentModel = model
                var entryInTheMiddle = model.get(iCnt % 2)
                routeMap.center = QtPositioning.coordinate(entryInTheMiddle.coord.latitude,entryInTheMiddle.coord.longitude)
            }
            searchString: "http://baugeschichte.at/app/v1/getData.php?action=getRoutePoints&name="
        }

    DensityHelpers {
        id: localHelper
    }


        MapComponent {
            id:routeMap
            anchors.centerIn: parent
            anchors.fill: parent
            center: locationGraz
            autoUpdatePois: false
            z: 32000
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
        }
    }

