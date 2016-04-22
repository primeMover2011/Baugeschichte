import QtQuick 2.4

Item {
    id: defaultHelper
    property real contentScaleFactor: screenDpi / 160
    property real textScaleFactor: 1
    function dp(value) {
        //console.log("value: "+ value + "screenDpi:" + screenDpi)
        return value * contentScaleFactor
    }

    function sp(value) {
        return value * contentScaleFactor * textScaleFactor
    }
}
