pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool running: false

    readonly property string icon: running ? "" : ""   // play / stop

    Process {
        id: check
        command: ["pgrep", "-f", "od-sender run"]
        onExited: (exitCode, exitStatus) => root.running = (exitCode === 0)
    }

    function refresh() {
        if (!check.running) check.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: recheck
        interval: 600
        onTriggered: root.refresh()
    }

    Timer {
        id: forceKill
        interval: 2000
        onTriggered: {
            if (root.running) {
                Quickshell.execDetached(["pkill", "-f", "od-sender run"])
                recheck.restart()
            }
        }
    }

    function toggle() {
        if (root.running) {
            Quickshell.execDetached(["od-sender", "stop"])
            forceKill.restart()
        } else {
            Quickshell.execDetached(["od-sender", "run"])
        }
        recheck.restart()
    }
}
