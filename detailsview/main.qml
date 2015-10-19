import QtQuick 2.5
import QtQuick.Window 2.2
//import "DetailsView" 1.0

Window {
    visible: true
    width: 600
    height: 800
    DetailsView {
        id: myDetailsView
        anchors.fill: parent
    }
}

