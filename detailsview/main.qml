import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4
import "./"


Window {
    visible: true
    id: appWindow
    width: 600
    height: 800
    Rectangle {
        color: "#060606"
        anchors.fill: parent

        StackView
        {
            id: uiStack
            initialItem: rgbComponent

            objectName: "theStackView"
            anchors.fill: parent

            RgbPage {
            id: rgbComponent
            //opacity: 0.5
            onSearch: {
                uiStack.push({item: Qt.resolvedUrl("DetailsView.qml"), properties: {searchFor:"Burggasse 15"}})
            }

            }

        }

    }
    //Rectangle







}
