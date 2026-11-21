// credit: @tony
// https://www.youtube.com/watch?v=g_I4hwCuDyQ
import Quickshell
import QtQuick
import "modules"
import "components"
import "bar"

// Timer refresing every 2s
Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
        CpuProc.running = true;
        RamProc.running = true;
    }
}
