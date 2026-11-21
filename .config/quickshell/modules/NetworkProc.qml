//credit @tony
// https://www.youtube.com/watch?v=g_I4hwCuDyQ
pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick
import "root:/"

Singleton {
    id: root

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var wiredDevice: Networking.devices.values.find(d => d.type !== DeviceType.Wifi && d.connected)
    property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

    readonly property bool wired: !!wiredDevice
    readonly property real signal: active ? active.signalStrength : 0

    readonly property string icon: {
        if (wired)
            return "";
        if (!Networking.wifiEnabled)
            return "󰖪";
        if (!active)
            return "󱚵";

        let tier = signal >= 0.75 ? 4 : signal >= 0.50 ? 3 : signal >= 0.25 ? 2 : 1;

        return String.fromCodePoint(0xF091F + (tier - 1) * 3);
    }

    readonly property string barTxt: icon
}
