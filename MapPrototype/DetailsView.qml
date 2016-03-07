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

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Window 2.0
import "./"

Item {
    property real itemSize: width / 3
    property string searchFor: ""

    DensityHelpers {
        id:localHelper
    }

    JsonModel {
        id: theDetails
        phrase: searchFor
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getBuildingDetail&name="
        onNewobject: {
            for (var key in magneto.payload) {
                var jsonObject = magneto.payload[key];
                jsonObject.detailText=jsonObject.text
                jsonObject.text = ""
                model.append(jsonObject);

            }
        }
        onIsLoaded: {
              console.debug("Reload DeatilsModel")

          }


    }


    ListView {
        id:                     mainListView
        anchors                 { fill: parent; margins: 10 }
        interactive:            false
        orientation:            ListView.Horizontal
        highlightMoveDuration:  250
        clip:                   false
        model:                  theDetails.model

        delegate:               Item {
            width:      mainListView.width
            height:     mainListView.height
//            anchors.fill: parent
        //+++ColumnLayout+++
            ColumnLayout {
                anchors.fill: parent

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

                    Layout.fillWidth:           true
                    Layout.fillHeight: true
//                    Layout.preferredHeight:     parent.height / 3
                    Layout.preferredHeight:     parent.height / 4
                    //anchors.top : parent.top
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

                                Image{
                                    id:myImage
                                    width: parent.width
                                    height: parent.height
                                    source: "http://baugeschichte.at/"+imageName
                                    fillMode: Image.PreserveAspectFit
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    smooth: true
                                }
                                Image {
                                    id: subImage
                                    width: myImage.width
                                    height: myImage.height
                                    source: "http://baugeschichte.at/"+imageName
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    smooth: true
                                    transform: Rotation { origin.x: 0; origin.y: parent.height; axis { x: 1; y: 0; z: 0 } angle: 180 }
                                }
                                Rectangle{
                                    y: myImage.height;
                                    x: -1
                                    width: myImage.width + 1
                                    height: myImage.height
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: Qt.rgba(0,0,0, 0.7) }
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




                        /*Image {
                        id: smallImage
                        height:     itemSize
                        width:      height
                        source:     "http://baugeschichte.at/"+imageName
                        fillMode:   Image.PreserveAspectFit
                        PinchArea {
                               anchors.fill: parent
                               pinch.target: smallImage
                               pinch.minimumRotation: -360
                               pinch.maximumRotation: 360
                               pinch.minimumScale: 0.1
                               pinch.maximumScale: 10
                               pinch.dragAxis: Pinch.XAndYAxis
                         //      onPinchStarted: setFrameColor();

                               MouseArea {
                                   anchors.fill: parent
                                   onClicked: {
                                       smallImage.height = 1000
                                       smallImage.width = 1000

                                   }

                        }
}


                        onSourceChanged: {
                            console.log("Source:",source)
                            console.log("imageName:",imageName)


                        }




                        Window {
                            id:         imageView
                            width: 800
                            height: 600
                            color: "#FFFCF2"
                            flags:      Qt.SplashScreen
                            Image {
                                anchors.fill: parent
                                source: smallImage.source
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: imageView.close()
                            }
                        }

                    }//IMAGE*/
                }
                }
                Rectangle {
                    id: textBase

                    Layout.fillWidth:   true
                    Layout.maximumHeight: parent.height * 0.75
                    Layout.minimumHeight: parent.height * 0.25
                    height: parent.height / 2
                    anchors.bottom: parent.bottom

                    color:          "#FFFCF2"
                    border.color:   "#8E8E8E"

                    TextEdit {
                        anchors             { fill: parent; margins: 5 }
                        readOnly:           true

                        wrapMode:           TextEdit.WordWrap
                        text:               detailText
                        font.pixelSize:     localHelper.sp(20)
                        color:              "#333333"
                    }
                }

                }//SplitView
            }
        //---ColumnLayout---
        }
    }

    Rectangle {
        anchors { left: parent.left; bottom: parent.bottom; margins: 10 }
        width: 100
        height: 100
        color: "red"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if ( mainListView.currentIndex != 0 ) {
                    mainListView.decrementCurrentIndex()
                } else mainListView.currentIndex = mainListView.count - 1
            }
        }
    }

    Rectangle {
        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        width: 100
        height: 100
        color: "blue"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if ( mainListView.currentIndex != mainListView.count - 1 ) {
                    mainListView.incrementCurrentIndex()
                } else mainListView.currentIndex = 0
            }
        }
    }
}
