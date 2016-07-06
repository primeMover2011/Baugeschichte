/**
 ** This file is part of the Baugeschichte.at project.
 **
 ** The MIT License (MIT)
 **
 ** Copyright (c) 2015 primeMover2011
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

#include "housemarker.h"

HouseMarker::HouseMarker()
{
}

void HouseMarker::setTitle(const QString& houseTitle)
{
    m_houseTitle = houseTitle;
}

const QString&HouseMarker::title() const
{
    return m_houseTitle;
}

void HouseMarker::setLocation(const QGeoCoordinate& theLocation)
{
    if (m_location == theLocation) {
        return;
    }

    m_location = theLocation;
}

const QGeoCoordinate&HouseMarker::location() const
{
    return m_location;
}

void HouseMarker::setCategories(const QString& categories)
{
    m_categories = categories;
}

const QString&HouseMarker::categories() const
{
    return m_categories;
}
