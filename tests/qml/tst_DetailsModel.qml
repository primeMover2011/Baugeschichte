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
import QtTest 1.1
import "../../src"

TestCase {
    name: "DetailsModelTests"

    DetailsModel {
        id: detailsModel
        searchString: "../../Baugeschichte/tests/qml/data/"
    }

    function cleanup() {
    }

    function test_load() {
        detailsModel.phrase = "details01.json";
        tryCompare(detailsModel, "isLoading", false, 1000, "Timed out readong json file");

        compare(detailsModel.modelDE.count, 3);
        compare(detailsModel.modelEN.count, 3);
        compare(detailsModel.modelS1.count, 0);

        compare(detailsModel.imagesModel.count, 5);
        compare(detailsModel.imagesModel.get(0).section, 0);
        compare(detailsModel.imagesModel.get(3).section, 1);
        compare(detailsModel.imagesModel.get(4).section, 2);
    }
}
