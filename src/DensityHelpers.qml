/**
 ** This file is part of the Baugeschichte.at project.
 **
 ** The MIT License (MIT)
 **
 ** Copyright (c) 2015 primeMover2011
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

import QtQuick 2.6

Item {
    id: defaultHelper

    readonly property int smallFontSize: Math.floor(fm.font.pixelSize * 1.1 * textScaleFactor)
    readonly property int defaultFontSize: Math.floor(fm.font.pixelSize * 1.3 * textScaleFactor)
    readonly property int largeFontSize: Math.floor(fm.font.pixelSize * 1.8 * textScaleFactor)

    property real contentScaleFactor: fm.font.pixelSize / 16.0
    property real textScaleFactor: 1

    function dp(value) {
        return Math.round(value * contentScaleFactor)
    }

    FontMetrics {
        id: fm
    }
}
