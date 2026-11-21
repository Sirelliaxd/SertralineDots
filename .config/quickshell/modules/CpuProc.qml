//credit @tony
// https://www.youtube.com/watch?v=g_I4hwCuDyQ
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/"

Singleton {
    id: root
    property alias running: cpuProc.running
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"] // read head of /proc/stat

        // SplitParser calling onRead for each line of stdout
        stdout: SplitParser {
            onRead: data => {
                // parse /proc/stat
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)));
                }
                lastCpuTotal = total;
                lastCpuIdle = idle;
            }
        }
        Component.onCompleted: running = true
    }

    property string barTxt: " " + cpuUsage + "%"
}
