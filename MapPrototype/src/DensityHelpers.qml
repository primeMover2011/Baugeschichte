import QtQuick 2.4

Item {
    id: defaultHelper

    readonly property int smallFontSize: Math.floor(fm.font.pixelSize * 1.1 * textScaleFactor)
    readonly property int defaultFontSize: Math.floor(fm.font.pixelSize * 1.3 * textScaleFactor)
    readonly property int largeFontSize: Math.floor(fm.font.pixelSize * 1.8 * textScaleFactor)

    property real contentScaleFactor: screenDpi / 160
    property real textScaleFactor: 1

    function dp(value) {
        return value * contentScaleFactor
    }

    FontMetrics {
        id: fm
    }
}
