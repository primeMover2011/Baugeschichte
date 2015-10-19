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



Item {

    ListModel {
        id: houseTrailImagesModel
        ListElement {
            entries : [
                ListElement {
                    title : "Letzte Ansicht"
                    text :"Ehemaliges \u0022Kommodhaus\u0022\n\nEckhaus mit Walmdach und fr\u00fchklassizistischer Plattenstilfassadierung, 1813 von Jakob Koll erbaut, 1839 durch Georg Hauberrisser um 2 Achsen verl\u00e4ngert. Der Bau war aus den Resten des ehemaligen Opernhauses am Tummelplatz hervorgegangen, dessen Vorg\u00e4nger wiederum von Erzherzo Karl II. erbaut, h\u00f6lzerne Wagenremisen der Lipizzaner waren. 1849 - 1855 befand sich das Haus im Besitz von Anton Sigl, dem Erbauer der Schlo\u00dfberg-Modelle.\nDas denkmalgesch\u00fctzte und keinesfalls einsturzgef\u00e4hrdete Geb\u00e4ude wurde im Jahre 2003 abgebrochen. Dies auf Grund eines Abbruchbescheides der Stadt Graz und trotz heftiger Proteste der Grazer Bev\u00f6lkerung.    \n\n(Nach: Andorfer, Opernhaus; Laukhardt, Kommodhaus)"
                    images :[
                        ListElement{
                            imageName:"images/b/b6/Z1_866a.jpg"
                            imageDescription:"(Foto AGIS - 2002)"
                        },
                        ListElement {
                            imageName:"images/8/84/Z1_866b.jpg"
                            imageDescription:"(Foto AGIS - 2002) "
                        }
                    ]
                },

                ListElement {
                    title:"Info: "
                    text:"Burggasse 15\n8010 Graz\nSteiermark\n\u00d6sterreich\n\n47\u00b04\u002712.58\u0022N,15\u00b026\u002740.57\u0022E\nmehr unter http:\/\/baugeschichte.at"
                    images :[
                        ListElement {
                            imageName:"skins/common/images/logo_baugeschichte.png"
                            imageDescription:"\nwww.baugeschichte.at "}
                    ]
                }
            ]



        }

    }

    property string titleText: "dialog.infotext"
    property string detailText: "dialog.detailText"

    width: parent.width
    height: parent.height

    GridLayout
    {
        anchors.fill: parent
        anchors.margins: 20
        rowSpacing: 20
        columnSpacing: 20
        flow:  width > height ? GridLayout.LeftToRight : GridLayout.TopToBottom

        Rectangle
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#5d5b59"
            ListView {
                anchors.fill: parent
                anchors.margins: 20
                clip: true
                id: smapleListView
                model: houseTrailImagesModel.entries
                Component.onCompleted: {
                    console.log("holladaria")                }

            delegate: Item {
               width: 800; height: 800
               //anchors.centerIn: parent
               Component.onCompleted: {
                   console.log("Item: itemwidth ", width)

               }
                Rectangle {
                    id: rootRect
                     width: 800; height: 800
                     anchors.centerIn: parent
                    Component.onCompleted: {
                        console.log("Rectangle rootrect: parentwidth ", parent.width)

                    }
                    Repeater {
                        model: images

                    Image {
                     id: imageItem
                     height: parent.height; width: parent.width
                     anchors.centerIn: parent
                     //anchors.left: parent.left
                     //anchors.right: parent.right

                     source: "http:\/\/baugeschichte.at\/"+images[0].imageName
                     fillMode: Image.PreserveAspectFit
                     cache: true
                        BusyIndicator {
                         running: imageItem.status === Image.Loading
                        }
                        Component.onCompleted: {
                            console.log("source: ", source)
                        }

                     }
                    Text {
                           // un-named element

                           // reference element by id
                           //top: imageItem.bottom + 20

                           // reference root element
                           width: rootRect.width

                           horizontalAlignment: Text.AlignHCenter
                           text: description
                       }
                    }

                }


            }
            }
        }

        Rectangle
        {
            id: textBase

            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#1e1b18"

            Text
            {
                id: headerText

                anchors
                {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    leftMargin: 5
                }

                height: 55
                text: titleText
                color: "white"
                font.pixelSize: 50
                font.bold: true
            }

            ScrollView
            {
                anchors
                {
                    left: parent.left
                    top: headerText.bottom
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: 5
                    leftMargin: 5
                }

                clip: true
                style: ScrollViewStyle {transientScrollBars: true}
                flickableItem.flickableDirection: Flickable.VerticalFlick

                Text
                {
                    width: textBase.width - 5 // Wären Anchors möglich, könnte man einfach Margins setzen...
            //        top: textBase.bottom + 5
                    text: detailText
                    wrapMode: Text.WordWrap
                    color: "white"
                    font.pixelSize: 40

                }
            }
        }
    }
 }
