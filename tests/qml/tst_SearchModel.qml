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
import qml 1.0

TestCase {
    name: "SearchModelTests"

    SearchModel {
        id: searchModel
//        searchString: "../../../Baugeschichte/tests/qml/data/"
        searchString: "data/"
    }

    function cleanup() {
    }

    function test_load() {
        searchModel.phrase = "search01.json";
        tryCompare(searchModel, "isLoading", false, 1000, "Timed out readong json file");

        compare(searchModel.model.count, 10);
        compare(searchModel.model.get(0).isBuilding, true);
    }

    function test_load_suggestions() {
        searchModel.phrase = "search02.json";
        tryCompare(searchModel, "isLoading", false, 1000, "Timed out readong json file");

        compare(searchModel.model.count, 2);
        compare(searchModel.model.get(0).isBuilding, false);
    }
}
