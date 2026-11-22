pragma Singleton

import Quickshell
import QtQuick
import "root:/"

// Visibility of the network dropdown
Singleton {
    id: root

    property bool visible: false

    property real anchorX: 0

    property var screen: null

    function show() {
        visible = true;
    }
    function hide() {
        visible = false;
    }
    function toggle() {
        visible = !visible;
    }
}
