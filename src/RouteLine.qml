import QtQuick 2.6
import QtQuick.XmlListModel 2.0
import QtLocation 5.6
import QtPositioning 5.6

MapPolyline {
    id: root

    line.width: 3
    line.color: "red"

    // Url for the KML file to show
    property url source
    onSourceChanged: {
        if (source == "") {
            clear();
        }
    }

    property bool loading: false

    XmlListModel {
        id: kmlLoaderV1

        source: root.source

        namespaceDeclarations: "declare default element namespace 'http://earth.google.com/kml/2.0';"
        query: "/kml/Document/Folder/Placemark/LineString"

        XmlRole { name: "coordinates"; query: "coordinates/string()" }

        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                parseKML();
            }
            if (status == XmlListModel.Error) {
                console.warn(qsTr("Error loading KML file ") + source + " : " + errorString())
            }

            checkLoading();
        }
    }

    XmlListModel {
        id: kmlLoaderV2

        source: root.source

        namespaceDeclarations: "declare default element namespace 'http://www.opengis.net/kml/2.2';"
        query: "/kml/Document/Folder/Placemark/LineString"

        XmlRole { name: "coordinates"; query: "coordinates/string()" }

        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                parseKML();
            }
            if (status == XmlListModel.Error) {
                console.warn(qsTr("Error loading KML file ") + source + " : " + errorString())
            }

            checkLoading();
        }
    }

    XmlListModel {
        id: kmlLoaderV3

        source: root.source

        namespaceDeclarations: "declare default element namespace 'http://earth.google.com/kml/2.2';"
        query: "/kml/Document/Placemark/LineString"

        XmlRole { name: "coordinates"; query: "coordinates/string()" }

        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                parseKML();
            }
            if (status == XmlListModel.Error) {
                console.warn(qsTr("Error loading KML file ") + source + " : " + errorString())
            }

            checkLoading();
        }
    }

    function clear()
    {
        while (root.pathLength() > 0) {
            root.removeCoordinate(0);
        }
        root.visible = false;
    }

    function parseKML()
    {
        if (kmlLoaderV1.count === 0 && kmlLoaderV2.count === 0 && kmlLoaderV3.count === 0) {
            checkLoading();
            return;
        }

        clear();

        var separator = " ";
        var kmlLoader = kmlLoaderV1;
        if (kmlLoaderV2.count !== 0) {
            kmlLoader = kmlLoaderV2;
        }
        if (kmlLoaderV3.count !== 0) {
            kmlLoader = kmlLoaderV3;
            separator = "\n";
        }

        for (var line=0; line<kmlLoader.count; ++line) {
            var coordinates = kmlLoader.get(line).coordinates.trim().split(separator);
            for (var i=0; i<coordinates.length; ++i) {
                var coords = coordinates[i].split(",");
                var position = QtPositioning.coordinate(coords[1], coords[0]);
                root.addCoordinate(position);
            }
        }

        checkLoading();
        root.visible = true;
    }

    function checkLoading() {
        root.loading = kmlLoaderV1.status == XmlListModel.Loading ||
                kmlLoaderV1.status == XmlListModel.Loading ||
                kmlLoaderV3.status == XmlListModel.Loading
    }
}
