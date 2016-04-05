/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import "./"

BaseView {
    id: root

    property real itemSize: width / 3
    property string searchFor: ""
    property string poiName: ""

    loading: theDetails.isLoading

    DensityHelpers {
        id:localHelper
    }

    JsonModel {
        id: theDetails
        phrase: searchFor
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getBuildingDetail&name="
        onNewobject: {
            poiName = magneto.title
            for (var key in magneto.payload) {
                var jsonObject = magneto.payload[key];
                jsonObject.detailText=jsonObject.text
                jsonObject.text = ""
                model.append(jsonObject);
            }
        }
    }

    Rectangle {
        id: initialTextbackground
        width: parent.width
        height:  parent.height / 2
        anchors.bottom: parent.bottom

        color: "#FFFCF2"
        border.color: "#8E8E8E"

        visible: mainListView.count === 0
    }

    ListView {
        id:                     mainListView
        anchors                 { fill: parent; /*margins: 10*/ }
        interactive:            false
        orientation:            ListView.Horizontal
        highlightMoveDuration:  250
        clip:                   false
        model:                  theDetails.model

        delegate:               Item {
            width:      mainListView.width
            height:     mainListView.height

            SplitView{
                anchors.fill: parent
                orientation: Qt.Vertical
                PathView {
                    id: imagePathView
                    focus: true
                    Keys.onLeftPressed: {
                        console.log("details: onpressleft")
                        decrementCurrentIndex()
                    }
                    Keys.onRightPressed: incrementCurrentIndex()
                    flickDeceleration: 390

                    width: parent.width
                    height: parent.height / 2
                    Layout.fillHeight: true
                    Layout.maximumHeight: parent.height * 0.75
                    Layout.minimumHeight: parent.height * 0.25
                    pathItemCount:              3
                    preferredHighlightBegin:    0.5
                    preferredHighlightEnd:      0.5
                    highlightRangeMode:         PathView.StrictlyEnforceRange
                    model:                      images
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

                        Image{
                            id:myImage
                            width: parent.width
                            height: parent.height
                            source: "http://baugeschichte.at/"+imageName
                            fillMode: Image.PreserveAspectFit
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            smooth: true
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
                                //anchors.verticalCenter: parent.verticalCenter
                                text: imageDescription
                                smooth: true
                                font.pixelSize: localHelper.sp(24)
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

                Rectangle {
                    id: textBase

                    width: parent.width
                    height: parent.height / 2
                    Layout.maximumHeight: parent.height * 0.75
                    Layout.minimumHeight: parent.height * 0.25

                    color: initialTextbackground.color
                    border.color: initialTextbackground.border.color

                    Text {
                        id: titleText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.margins: localHelper.dp(5)
                        //anchors.verticalCenter: parent.verticalCenter
                        text: poiName + ": " + title
                        smooth: true
                        font.pixelSize: localHelper.sp(24)

                    }

                    TextArea {
                        anchors { top: titleText.bottom;
                            bottom: parent.bottom; left: parent.left;
                            right: parent.right; margins: 5 }
                        readOnly:           true
                        verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
                        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                        wrapMode:           TextEdit.WordWrap
                        text:               (detailText.length > 0) ? detailText : "Kein Text"
                        font.pixelSize:     localHelper.sp(20)
                        //color:              "#333333"
                    }

                    Keys.onLeftPressed: console.log("onLeft Details")
                    Keys.onRightPressed: console.log("onLeft Details")
                }
            }//SplitView
        }
    }

    Image {
        id:prevImage
        anchors { left: parent.left; bottom: parent.bottom; margins: 10 }
        source: "resources/Go-previous.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        width: localHelper.dp(100)
        height: localHelper.dp(100)
        MouseArea {
            anchors.fill: parent

            onClicked: {
                if ( mainListView.currentIndex != 0 ) {
                    mainListView.decrementCurrentIndex()
                } else {
                    mainListView.currentIndex = mainListView.count - 1
                }
            }
        }
    }
    Image {
        id:nextImage
        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        width: localHelper.dp(100)
        height: localHelper.dp(100)

        source: "resources/Go-next.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if ( mainListView.currentIndex != mainListView.count - 1 ) {
                    mainListView.incrementCurrentIndex()
                } else {
                    mainListView.currentIndex = 0
                }
            }
        }
    }
}
