import QtQuick 2.4
import QtLocation 5.5

MapQuickItem {
    id: root

    property alias title: textItem.text
    property int id: -1
    property Map mapItem
    
    anchorPoint.x: coco.width / 2
    anchorPoint.y: coco.height * 1.9
    
    sourceItem: Rectangle {
        id: coco
        
        color: "#ffffff"
        border.width: 1
        border.color: "#e02222"
        width: textItem.width * 1.2
        height: textItem.height * 1.5
        radius: 3
        
        Text {
            id: textItem
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "Text"
            font.pixelSize: localHelper.defaultFontSize
            color: "#ff0000"
            font.bold: true
        }
        
        MouseArea {
            id: rectMouse
            preventStealing: true
            anchors.fill: parent
            onClicked: selectPoi(root.title)

            function selectPoi(aTitle) {
                console.log("textItem poi selected...")
                mapItem.selectedPoi = aTitle
                appCore.selectedHouseId = root.id;

                mapItem.center = root.coordinate;
                if (mapItem.zoomLevel < 18) {
                    mapItem.zoomLevel = 19;
                }

                root.destroy();
            }
        }
    }
}
