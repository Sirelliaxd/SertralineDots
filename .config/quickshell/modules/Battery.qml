// credit @saneaspect
// https://www.youtube.com/watch?v=Vlpyz4c4Xdw&t=2815s
pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick
import "root:/"

Singleton {
    property var battery: UPower.displayDevice
    property bool charging: battery.state === UPowerDeviceState.Charging
    property bool homed: battery.state === UPowerDeviceState.FullyCharged
    readonly property int level: Math.round(battery.percentage * 100)

    readonly property string icon: {
        if (homed)
            return "󱤁";
        if (charging)
            return "";
        if (level >= 100)
            return "";
        if (level >= 75)
            return "";
        if (level >= 50)
            return "";
        if (level >= 25)
            return "";
        if (level < 25)
            return "";

        return "󰂑";
    }

    property string barTxt: icon + " " + level + "%"
}
