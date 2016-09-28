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
    property string poiName: detailsModel.title

    loading: detailsModel.isLoading
    onLoadingChanged: {
        if (!loading) {
            selectLanguage();
        }
    }

    function selectLanguage() {
        // get from last manual setting
        if (appCore.detailsLanguage === "DE" && detailsModel.modelDE.count > 0) {
            mainListView.model = detailsModel.modelDE;
            return;
        }
        if (appCore.detailsLanguage === "EN" && detailsModel.modelEN.count > 0) {
            mainListView.model = detailsModel.modelEN;
            return;
        }
        if (appCore.detailsLanguage === "S1" && detailsModel.modelS1.count > 0) {
            mainListView.model = detailsModel.modelS1;
            return;
        }

        // auto fallback
        if (detailsModel.modelDE.count > 0) {
            mainListView.model = detailsModel.modelDE;
            return;
        }
        if (detailsModel.modelEN.count > 0) {
            mainListView.model = detailsModel.modelEN;
            return;
        }
        if (detailsModel.modelS1.count > 0) {
            mainListView.model = detailsModel.modelS1;
            return;
        }
    }

    DetailsModel {
        id: detailsModel
        title: phrase
        phrase: root.visible ? root.searchFor : ""
        onPhraseChanged: {
            imagePathView.currentIndex = 0;
            mainListView.currentIndex = 0;
        }
    }

    DensityHelpers {
        id:localHelper
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
    }

    Rectangle {
        id: initialTextbackground
        width: parent.width
        height:  mainListView.height
        anchors.bottom: parent.bottom

        color: "#FFFCF2"
        border.color: "#8E8E8E"
    }

    SplitView {
        id: splitView
        anchors {
            top: parent.top
            bottom: prevImage.visible || nextImage.visible || languageSwitch.visible ? languageSwitch.top : parent.bottom
            left: parent.left
            right: parent.right
        }

        orientation: Qt.Vertical

        ImageCarousel {
            id: imagePathView

            height: parent.height / 2
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.75
            Layout.minimumHeight: parent.height * 0.25

            model: detailsModel.imagesModel

            onCurrentIndexChanged: {
                if (currentIndex < 0 || currentIndex >= detailsModel.imagesModel.count) {
                    return;
                }

                var section = detailsModel.imagesModel.get(currentIndex).section;
                if (mainListView !== section) {
                    mainListView.currentIndex = section;
                }
            }

            function showImageForText() {
                if (detailsModel.imagesModel.count === 0 ||
                        detailsModel.imagesModel.get(currentIndex).section === mainListView.currentIndex) {
                    // already correct section
                    return;
                }

                for (var i=0; i<model.count; ++i) {
                    var section = detailsModel.imagesModel.get(i).section;
                    if (section === mainListView.currentIndex) {
                        currentIndex = i;
                        return;
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: qsTr("No image")
                color: "white"
                visible: imagePathView.model.count === 0 && !detailsModel.isLoading
            }

        }

        ListView {
            id: mainListView

            height: parent.height / 2
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.75
//            Layout.minimumHeight: parent.height * 0.25

            interactive: false
            orientation: ListView.Horizontal
            highlightMoveDuration: 250
            clip: false
            model: detailsModel.modelDE

            onCurrentIndexChanged: {
                imagePathView.showImageForText()
            }

            delegate: Item {
                width: mainListView.width
                height: Math.max(mainListView.height, splitView.height * 0.25)

                Rectangle {
                    id: textBase

                    width: parent.width
                    height: parent.height

                    color: initialTextbackground.color
                    border.color: initialTextbackground.border.color

                    Text {
                        id: titleText
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: localHelper.dp(5)
                        horizontalAlignment: Text.AlignHCenter
                        text: (poiName !== "") ? (poiName + ": " + title) : title
//                        smooth: true
                        font.pixelSize: localHelper.defaultFontSize
                        wrapMode: Text.Wrap
                    }

                    TextArea {
                        anchors { top: titleText.bottom;
                            bottom: parent.bottom; left: parent.left;
                            right: parent.right; margins: 5
                        }
                        readOnly: true
                        verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
                        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                        wrapMode: TextEdit.WordWrap
                        text: (detailText.length > 0) ? detailText : qsTr("Kein Text")
                        textFormat: TextEdit.RichText
                        font.pixelSize: localHelper.smallFontSize

                        onLinkActivated: {
                            appCore.openExternalLink(link);
                        }
                    }

                    Keys.onLeftPressed: console.log("onLeft Details")
                    Keys.onRightPressed: console.log("onLeft Details")
                }
            }
        }
    } //SplitView

    Image {
        id:prevImage
        anchors { left: parent.left; bottom: parent.bottom; margins: 10 }
        width: localHelper.dp(50)
        height: localHelper.dp(50)

        source: "resources/Go-previous.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: mainListView.model.count > 1

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
        id: languageSwitch
        anchors {
            bottom: parent.bottom;
            horizontalCenter: parent.horizontalCenter;
            margins: 10
        }
        width: localHelper.dp(50)
        height: width

        source: mainListView.model === detailsModel.modelDE ? "resources/Flag_of_Germany.png" :
                                             mainListView.model === detailsModel.modelEN ? "resources/Flag_of_United_Kingdom.png"
                                                                        : ""

        visible: twoOrMoreLanguages()

        Text {
            anchors.centerIn: parent
            text: parent.source == "" ? "L1" : ""
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if (mainListView.model === detailsModel.modelDE) {
                    if (detailsModel.modelEN.count > 0) {
                        mainListView.model = detailsModel.modelEN;
                        appCore.detailsLanguage = "EN";
                        return;
                    }
                    if (detailsModel.modelS1.count > 0) {
                        mainListView.model = detailsModel.modelS1;
                        appCore.detailsLanguage = "S1";
                        return;
                    }
                }

                if (mainListView.model === detailsModel.modelEN) {
                    if (detailsModel.modelS1.count > 0) {
                        mainListView.model = detailsModel.modelS1;
                        appCore.detailsLanguage = "S1";
                        return;
                    }
                    if (detailsModel.modelDE.count > 0) {
                        mainListView.model = detailsModel.modelDE;
                        appCore.detailsLanguage = "DE";
                        return;
                    }
                }

                if (mainListView.model === detailsModel.modelS1) {
                    if (detailsModel.modelDE.count > 0) {
                        rmainListView.model = detailsModel.modelDE;
                        appCore.detailsLanguage = "DE";
                        return;
                    }
                    if (detailsModel.modelEN.count > 0) {
                        mainListView.model = detailsModel.modelEN;
                        appCore.detailsLanguage = "EN";
                        return;
                    }
                }
            }
        }

        function twoOrMoreLanguages() {
            var languages = 0;
            if (detailsModel.modelDE.count > 0) {
                languages += 1;
            }
            if (detailsModel.modelEN.count > 0) {
                languages += 1;
            }
            if (detailsModel.modelEN.count > 0) {
                languages += 1;
            }
            return languages >= 2;
        }
    }

    Image {
        id:nextImage
        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        width: localHelper.dp(50)
        height: localHelper.dp(50)

        source: "resources/Go-next.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: mainListView.model.count > 1

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
