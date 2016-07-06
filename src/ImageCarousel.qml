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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import "./"

/**
 Carousel in the details view showing the fotos of the building
 */
PathView {
    id: imagePathView
    focus: true

    Keys.onLeftPressed: {
        decrementCurrentIndex();
    }

    Keys.onRightPressed: {
        incrementCurrentIndex();
    }

    flickDeceleration: 390
    
    pathItemCount:              3
    preferredHighlightBegin:    0.5
    preferredHighlightEnd:      0.5
    highlightRangeMode:         PathView.StrictlyEnforceRange

    path: Path {
        id: myPath
        startX: 0; startY: imagePathView.height / 2 //parent.height / 6
        PathAttribute {name: "rotateY"; value: 50.0}
        PathAttribute {name: "scalePic"; value: 0.2}
        PathAttribute {name: "zOrder"; value: 1}
        
        PathLine{x:imagePathView.width/4; y: imagePathView.height/ 2}
        PathPercent {value: 0.44}
        PathAttribute {name: "rotateY"; value: 50.0}
        PathAttribute {name: "scalePic"; value: 0.5}
        PathAttribute {name: "zOrder"; value: 10}
        
        PathQuad{x:imagePathView.width/2; y: imagePathView.height / 2.2 ; controlX: imagePathView.width/2.2; controlY: imagePathView.height / 2.2 }
        PathPercent {value: 0.50}
        PathAttribute {name: "rotateY"; value: 0.0}
        PathAttribute {name: "scalePic"; value: 1.0}
        PathAttribute {name: "zOrder"; value: 50}
        
        PathQuad{x:imagePathView.width * 0.75; y: imagePathView.height / 2 ; controlX: imagePathView.width * 0.78; controlY: imagePathView.height / 2}
        PathPercent {value: 0.56}
        PathAttribute {name: "rotateY"; value: -50.0}
        PathAttribute {name: "scalePic"; value: 0.5}
        PathAttribute {name: "zOrder"; value: 10}
        
        PathLine{x:imagePathView.width; y: imagePathView.height / 2}
        PathPercent {value: 1.00}
        PathAttribute {name: "rotateY"; value: -50.0}
        PathAttribute {name: "scalePic"; value: 0.2}
        PathAttribute {name: "zOrder"; value: 1}
    }
    
    delegate:
        Item{
        id: imageContainer
        property real tmpAngle : PathView.rotateY
        property real scaleValue: PathView.scalePic
        width: parent.width
        height: parent.height
        visible: PathView.onPath
        z: PathView.zOrder
        anchors.top:parent.top
        
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
        
        transform:[
            Rotation{
                angle: tmpAngle
                origin.x: myImage.width/2
                axis { x: 0; y: 1; z: 0 }
            },
            Scale {
                xScale:scaleValue; yScale:scaleValue
                origin.x: myImage.width/2;   origin.y: myImage.height/2
            }
        ]
    }
}
