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

#ifndef HOUSEMARKER_H
#define HOUSEMARKER_H

#include <QGeoCoordinate>
#include <QString>

/**
 * @brief The HouseMarker class contains the data for a marker on the map
 */
class HouseMarker
{
public:
    explicit HouseMarker();

    const QString& houseTitle() const
    {
        return m_houseTitle;
    }

    const QGeoCoordinate& location() const
    {
        return m_location;
    }

    const QString& categories() const
    {
        return m_categories;
    }

    void setHouseTitle(const QString& houseTitle);
    void setLocation(const QGeoCoordinate& location);
    void setCategories(const QString& categories);

protected:
    QString m_houseTitle;
    QGeoCoordinate m_location;
    QString m_categories;
};

inline bool operator<(const HouseMarker& lhs, const HouseMarker& rhs)
{
    return lhs.houseTitle() < rhs.houseTitle();
}

#endif // HOUSEMARKER_H
