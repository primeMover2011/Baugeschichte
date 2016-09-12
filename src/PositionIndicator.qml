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

import QtQuick 2.5
import QtLocation 5.5
import QtPositioning 5.5

/**
 MapItem to indicate the current position
 */
MapQuickItem {
    id: root

    property var positionSource

    coordinate: positionSource.position.coordinate

    anchorPoint.x: positionCircle.width / 2
    anchorPoint.y: positionCircle.height / 2

    DensityHelpers {
        id: localHelper
    }

    sourceItem: Rectangle {
        id: positionCircle
        color: "#00a200"
        border.color: "#190a33"
        border.width: 2
        smooth: true
        opacity: 0.5
        width: localHelper.dp(90)
        height: width
        radius: width/2

        SequentialAnimation on width {
            loops: Animation.Infinite
            NumberAnimation {
                from: positionCircle.width
                to: positionCircle.width * 1.8
                duration: 800
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                from: positionCircle.width * 1.8
                to: positionCircle.width
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
    }
}
