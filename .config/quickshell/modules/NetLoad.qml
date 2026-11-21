pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/"

// Throughput of one interface, sampled from /proc/net/dev while the network menu is open.
// The menu calls start(device) when it opens and stop() when the window is destroyed, so the
// timer only runs while somebody is looking at the graph.
Singleton {
    id: root

    property string device: ""
    property real rxRate: 0  // bytes per second
    property real txRate: 0
    property var history: []  // one entry per interval, oldest first

    property var lastRx: -1
    property var lastTx: -1
    property var lastTime: 0

    property alias running: sampler.running

    Timer {
        id: sampler
        interval: Theme.networkDropdownGraphInterval
        repeat: true
        onTriggered: devProc.running = true
    }

    Process {
        id: devProc
        command: ["sh", "-c", "cat /proc/net/dev"]
        stdout: SplitParser {
            onRead: data => root.sample(data)
        }
    }

    // One line of /proc/net/dev is "name: <16 numbers>", received bytes first and transmitted
    // bytes ninth. Rates come from the difference between two samples
    function sample(line) {
        var parts = line.split(":");
        if (parts.length < 2 || parts[0].trim() !== root.device)
            return;
        var nums = parts[1].trim().split(/\s+/).map(Number);
        if (nums.length < 9)
            return;

        var now = Date.now();
        var dt = (now - root.lastTime) / 1000;
        if (root.lastTime > 0 && dt > 0) {
            root.rxRate = Math.max(0, (nums[0] - root.lastRx) / dt);
            root.txRate = Math.max(0, (nums[8] - root.lastTx) / dt);
            var list = root.history.slice();
            list.push({
                rx: root.rxRate,
                tx: root.txRate
            });
            while (list.length > Theme.networkDropdownGraphSamples)
                list.shift();
            root.history = list;
        }
        root.lastRx = nums[0];
        root.lastTx = nums[8];
        root.lastTime = now;
    }

    function start(dev) {
        if (root.device !== dev)
            root.reset();
        root.device = dev;
        if (dev === "")
            return;
        root.running = true;
        devProc.running = true;  // sample now, so the first interval already has counters
    }

    function stop() {
        root.running = false;
    }

    function reset() {
        root.history = [];
        root.rxRate = 0;
        root.txRate = 0;
        root.lastRx = -1;
        root.lastTx = -1;
        root.lastTime = 0;
    }

    function formatRate(bytes) {
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + " MB/s";
        if (bytes >= 1024)
            return (bytes / 1024).toFixed(1) + " kB/s";
        return Math.round(bytes) + " B/s";
    }
}
