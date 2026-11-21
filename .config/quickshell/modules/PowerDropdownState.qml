pragma Singleton

import Quickshell
import QtQuick
import "root:/"

// Visibility of the power dropdown.
Singleton {
    id: root

    property bool visible: false

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
