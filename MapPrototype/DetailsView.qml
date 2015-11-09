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

Item {
    property real itemSize: width / 3
    property string searchFor: ""

    ListModel {
        id: houseTrailImagesModel

        ListElement {
            area: "letzte Ansicht"
            title: "Letzte Ansicht"
            textString: "Ehemaliges \u0022Kommodhaus\u0022\n\nEckhaus mit Walmdach und fr\u00fchklassizistischer Plattenstilfassadierung, 1813 von Jakob Koll erbaut, 1839 durch Georg Hauberrisser um 2 Achsen verl\u00e4ngert. Der Bau war aus den Resten des ehemaligen Opernhauses am Tummelplatz hervorgegangen, dessen Vorg\u00e4nger wiederum von Erzherzo Karl II. erbaut, h\u00f6lzerne Wagenremisen der Lipizzaner waren. 1849 - 1855 befand sich das Haus im Besitz von Anton Sigl, dem Erbauer der Schlo\u00dfberg-Modelle.\nDas denkmalgesch\u00fctzte und keinesfalls einsturzgef\u00e4hrdete Geb\u00e4ude wurde im Jahre 2003 abgebrochen. Dies auf Grund eines Abbruchbescheides der Stadt Graz und trotz heftiger Proteste der Grazer Bev\u00f6lkerung.    \n\n(Nach: Andorfer, Opernhaus; Laukhardt, Kommodhaus)"
            images: [
                ListElement{
                    area: "image"
                    imageName:"images/img1.jpg"
                    imageDescription:"(Foto AGIS - 2002)"
                },
                ListElement {
                    area: "image2"
                    imageName:"images/img2.jpg"
                    imageDescription:"(Foto AGIS - 2002) "
                },
                ListElement {
                    area: "image2"
                    imageName:"images/img4.jpg"
                    imageDescription:"(Foto AGIS - 2002) "
                },
                ListElement {
                    area: "image2"
                    imageName:"images/img5.jpg"
                    imageDescription:"(Foto AGIS - 2002) "
                },
                ListElement {
                    area: "image2"
                    imageName:"images/img6.jpg"
                    imageDescription:"(Foto AGIS - 2002) "
                }
            ]
        }
        ListElement {
            area:"Info"
            title:"Info: "
            textString:"Burggasse 15\n8010 Graz\nSteiermark\n\u00d6sterreich\n\n47\u00b04\u002712.58\u0022N,15\u00b026\u002740.57\u0022E\nmehr unter http:\/\/baugeschichte.at"
            images: [
                ListElement {
                    area: "impfo"
                    imageName:"images/img3.jpg"
                    imageDescription:"\nwww.baugeschichte.at "}
            ]
        }
    }

/*    DetailsModel {
      id: theDetails
      phrase: searchFor
      searchString: "http://baugeschichte.at/app/v1/getData.php?action=getBuildingDetail&name="
      onIsLoaded: {
            console.debug("Reload DeatilsModel")

        }
    }
  */
    JsonModel {
        id: theDetails
        phrase: searchFor
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getBuildingDetail&name="
        onNewobject: {
            for (var key in magneto) {
                var jsonObject = magneto[key];
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
        clip:                   true
        model:                  theDetails.model
        delegate:               Item {
            width:      mainListView.width
            height:     mainListView.height

            ColumnLayout {
                anchors.fill: parent

                PathView {
                    id: imagePathView

                    Layout.fillWidth:           true
                    Layout.preferredHeight:     parent.height / 3
                    pathItemCount:              3
                    preferredHighlightBegin:    0.5
                    preferredHighlightEnd:      0.5
                    highlightRangeMode:         PathView.StrictlyEnforceRange
                    model:                      images
                    path: Path {
                        startX: 0
                        startY: imagePathView.height / 2
                        PathQuad {
                            x: imagePathView.width
                            y: imagePathView.height / 2
                            controlX: imagePathView.width / 2
                            controlY: imagePathView.height / 2
                        }
                    }
                    delegate: Image {
                        height:     itemSize
                        width:      height
                        source:     "http://baugeschichte.at/"+imageName
                        fillMode:   Image.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent
                            onClicked: imageView.show()
                        }
                        onSourceChanged: {
                            console.log("Source:",source)
                            console.log("imageName:",imageName)


                        }

                  /*      Window {
                            id:         imageView
                            width: 800
                            height: 600
                            color: "#FFFCF2"
                            flags:      Qt.SplashScreen
                            Image {
                                anchors.fill: parent
                                source: imageName
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: imageView.close()
                            }
                        }
                */
                    }
                }

                Rectangle {
                    id: textBase

                    Layout.fillWidth:   true
                    Layout.fillHeight:  true

                    color:          "#FFFCF2"
                    border.color:   "#8E8E8E"

                    TextEdit {
                        anchors             { fill: parent; margins: 5 }
                        readOnly:           true

                        wrapMode:           TextEdit.WordWrap
                        text:               detailText
                        color:              "#333333"
                    }
                }
            }
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
