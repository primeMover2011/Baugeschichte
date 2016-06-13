import QtQuick 2.6
import QtTest 1.1
import "../../src"

TestCase {
    name: "RouteLineTests"

    RouteLine {
        id: routeLine
    }

    function cleanup() {
        routeLine.clear();
    }

    function test_load() {
        routeLine.source = "data/Landpartie.kml"
        tryCompare(routeLine, "loading", false, 500);
        compare(routeLine.pathLength(), 51);
    }

    function test_reload() {
        routeLine.source = "data/Landpartie.kml"
        routeLine.source = ""
        routeLine.source = "data/Landpartie.kml"
        tryCompare(routeLine, "loading", false, 500);
        compare(routeLine.pathLength(), 51);
    }

    function test_kml_style_2() {
        routeLine.source = "data/Rundgang_Herz-Jesu.kml"
        tryCompare(routeLine, "loading", false, 500);
        compare(routeLine.pathLength(), 37);
    }

    function test_kml_style_3() {
        routeLine.source = "data/FugngerroutemitdemZielLendkai35Graz.kml"
        tryCompare(routeLine, "loading", false, 500);
        compare(routeLine.pathLength(), 19);
    }
}
