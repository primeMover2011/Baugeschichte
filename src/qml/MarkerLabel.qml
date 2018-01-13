/**
 ** This file is part of the Baugeschichte.at project.
 **
 ** The MIT License (MIT)
 **
 ** Copyright (c) 2016 Guenter Schwann
 **
 ** Permission is hereby granted, free of charge, to any person obtaining a copy
 ** of this software and associated documentation files (the "Software"), to deal
 ** in the Software without restriction, including without limitation the rights
 ** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ** copies of the Software, and to permit persons to whom the Software is
 ** furnished to do so, subject to the following conditions:
 **
 ** The above copyright notice and this permission notice shall be included in all
 ** copies or substantial portions of the Software.
 **
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 ** SOFTWARE.
 **/

import QtQuick 2.4
import QtLocation 5.5
import "."

MapQuickItem {
    id: root

    readonly property string title: textItem.text
    property Map mapItem

    anchorPoint.x: coco.width / 2
    anchorPoint.y: (coco.height + (mapItem ? mapItem.markerSize / mapItem.scale : 0) * 0.9) + 2

    scale: mapItem ? (1.0 / mapItem.scale) : 1.0
    visible: title !== ""

    coordinate: appCore.selectedHousePosition

    sourceItem: Rectangle {
        id: coco

        color: "#ffffff"
        border.width: 1
        border.color: "#0048a0"
        width: textItem.width * 1.2
        height: textItem.height * 1.5
        radius: 3

        Text {
            id: textItem
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: appCore.selectedHouse
            font.pixelSize: Theme.defaultFontSize
            color: "#0063DD"
            font.bold: true
        }

        MultiPointTouchArea {
            anchors.fill: parent

            onReleased:selectPoi();

            function selectPoi() {
                appCore.selectedHouse = root.title;
                appCore.showDetails = true;
                appCore.centerSelectedHouse();
            }
        }
    }
}
