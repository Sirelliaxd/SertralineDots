//credit @tony
// https://www.youtube.com/watch?v=g_I4hwCuDyQ
pragma Singleton

import Quickshell
import QtQuick
import "root:/"

// Visibility of the volume dropdown. The bar's volume readout and the menu share it.
Singleton {
    id: root

    property bool visible: false

    property real anchorX: 0

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
