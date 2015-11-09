import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtPositioning 5.5
import QtLocation 5.5

ApplicationWindow {

    visible: true
    //    PositionSource
    property variant locationGraz: QtPositioning.coordinate(47.0666667, 15.45)
    Component.onCompleted: {
        dialog.getAllPois();
    }

/*    Connections {
        target: mapOfEurope
        onSelectedPoiChanged: {
            console.log("Poi:", mapOfEurope.selectedPoi)
        }
    }
    */

    Rectangle {
        color: "#060606"
        anchors.fill: parent
        Keys.onReleased: {
            console.log("Keys.onrelease")
            if (event.key === Qt.Key_Back && uiStack.depth > 1) {
                             uiStack.pop();
                             event.accepted = true;
                         }
        }

        StackView
        {
            id: uiStack
            initialItem: mapOfEurope



            objectName: "theStackView"
            anchors.fill: parent
            MapComponent {
                id: mapOfEurope
                anchors.centerIn: parent;
                anchors.fill: parent
                center: locationGraz
                onSelectedPoiChanged: {
                    console.log("SelectedPoiChanged Begin")
                    uiStack.push({item: Qt.resolvedUrl("DetailsView.qml"), properties: {searchFor:selectedPoi}})
                    console.log("SelectedPoiChanged End")
                }
                onSearch: {
                    uiStack.push({item: Qt.resolvedUrl("SearchPage.qml"), properties: {searchFor:selectedPoi}})
                }

            }

/*            RgbPage {
            id: rgbComponent
            //opacity: 0.5
            onSearch: {
                uiStack.push({item: Qt.resolvedUrl("DetailsView.qml"), properties: {searchFor:"Burggasse 15"}})
            }

            }*/

        }

    }
    //Rectangle


}
