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

import QtQuick 2.6

/**
 Carousel in the details view showing the fotos of the building
 */
ListView {
    id: root

    focus: true
    clip: true

    Keys.onLeftPressed: {
        decrementCurrentIndex();
    }

    Keys.onRightPressed: {
        incrementCurrentIndex();
    }

    orientation: ListView.Horizontal
    snapMode:
        ListView.SnapToItem
    
    delegate: Item {
        id: imageContainer

        width: root.width
        height: root.height

        Image {
            id:myImage
            width: parent.width
            height: parent.height
            source: imageUrl(imageName)
            fillMode: Image.PreserveAspectFit
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            smooth: true
            asynchronous: true
            
            function imageUrl(imageName) {
                var isRemote = imageName.substring(0, 4) === "http";
                if (isRemote) {
                    return imageName;
                } else {
                    var url = "http://baugeschichte.at/" + imageName;
                    url += "?iiurlwidth=640"; // load in 640px resolution
                    return url;
                }
            }
            
            Text {
                id: loadError
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                color: "red"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text:qsTr("Failure loading iamge from\n") + myImage.source
                visible: myImage.status === Image.Error
            }
        }
        Rectangle {
            id: textRect
            width: textItem.width
            height: textItem.height
            anchors.bottom: myImage.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            smooth: true
            Text {
                id: textItem
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(implicitWidth, imageContainer.width)
                text: imageDescription
                smooth: true
                font.pixelSize: localHelper.smallFontSize
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }
    }
}
