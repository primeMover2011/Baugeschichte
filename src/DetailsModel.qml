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

JsonModel {
    id: root

    property string title: ""

    property variant modelDE: model
    property ListModel modelEN: ListModel {}
    property ListModel modelS1: ListModel {}

    property ListModel imagesModel: ListModel {}

    function clear() {
        modelDE.clear();
        modelEN.clear();
        modelS1.clear();
        imagesModel.clear();
    }

    searchString: "http://baugeschichte.at/app/v1/getData.php?action=getBuildingDetail&name="

    onPhraseChanged: {
        clear();
    }

    onNewobject: {
        clear();

        if (magneto.version !== "1") {
            console.warn("Unknown version for details: "+magneto.version)
        }

        var section = -1;

        title = magneto.title
        for (var key in magneto.payload) {
            var jsonObject = magneto.payload[key];
            if (jsonObject.title === null) {
                jsonObject.title = ""
            }

            var resultObject = {}
            resultObject.title = jsonObject.title;

            if (jsonObject.title.trim() !== "Info") {
                resultObject.detailText = jsonObject.text

                if (jsonObject.lang === undefined) {
                    jsonObject.lang = ""
                }

                if (jsonObject.lang === "de") {
                    ++section;
                    model.append(resultObject);
                } else if (jsonObject.lang === "en") {
                    modelEN.append(resultObject);
                } else {
                    modelS1.append(resultObject);
                }

                for (var idx in jsonObject.images) {
                    var img = jsonObject.images[idx];
                    img.section = section;
                    imagesModel.append(img);
                }
            }
        }
    }
    onErrorChanged: {
        console.log("Error: " + error);
        title = "";
        if (error !== "") {
            console.log("Error: " + error);
            var jsonObject = {"detailText": error, "title": qsTr("Load error")};
            model.append(jsonObject);
        }
    }
}
