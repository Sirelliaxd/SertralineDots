pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtCore
import "root:/"

// Everything the bluetooth menu and the bar readout need
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool hasAdapter: adapter !== null
    readonly property bool powered: hasAdapter && adapter.enabled
    readonly property bool pairable: hasAdapter && adapter.pairable
    readonly property bool discoverable: hasAdapter && adapter.discoverable
    readonly property bool scanning: hasAdapter && adapter.discovering

    // Every device the adapter knows: paired ones first, pinned ones above those, then the rest
    // by name. `devices` is the adapter's own model, so this is all of them.
    // The service fills these in as BlueZ answers, so they can be undefined for a moment
    readonly property string adapterId: hasAdapter && adapter.adapterId ? adapter.adapterId : ""
    readonly property string adapterLabel: hasAdapter ? (adapter.alias ? adapter.alias : (adapter.name ? adapter.name : "")) : ""

    readonly property var devices: {
        if (!hasAdapter || !adapter.devices || adapter.devices.values === undefined)
            return [];
        var list = adapter.devices.values.filter(d => d.name !== "" || d.deviceName !== "");
        return list.sort((a, b) => {
            var pa = root.isPinned(a.address);
            var pb = root.isPinned(b.address);
            if (pa !== pb)
                return pa ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            return root.deviceLabel(a).localeCompare(root.deviceLabel(b));
        });
    }

    readonly property var paired: devices.filter(d => d.paired)
    readonly property var found: devices.filter(d => !d.paired)

    // ---- pinned devices
    property var pinned: []

    property var _settings: Settings {
        category: "Bluetooth"
        location: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/quickshell/bluetooth.ini"
        property string pinnedSerialized: "[]"
    }

    Component.onCompleted: {
        pinned = JSON.parse(_settings.pinnedSerialized);
    }

    function isPinned(address) {
        return pinned.indexOf(address) >= 0;
    }

    function togglePin(address) {
        var list = pinned.slice();
        var idx = list.indexOf(address);
        if (idx >= 0)
            list.splice(idx, 1);
        else
            list.push(address);
        pinned = list;
        _settings.pinnedSerialized = JSON.stringify(list);
    }

    // ---- what a row shows
    // A device that has never been given a name reports its address
    function deviceLabel(device) {
        var name = device.name !== "" ? device.name : device.deviceName;
        return name !== "" ? name : device.address;
    }

    // BlueZ reports an icon name per device class
    function deviceIcon(device) {
        var icon = device.icon;
        if (icon.indexOf("headset") >= 0)
            return Theme.bluetoothDropdownHeadsetIcon;
        if (icon.indexOf("headphone") >= 0)
            return Theme.bluetoothDropdownHeadphonesIcon;
        if (icon.indexOf("audio") >= 0 || icon.indexOf("speaker") >= 0)
            return Theme.bluetoothDropdownSpeakerIcon;
        if (icon.indexOf("keyboard") >= 0)
            return Theme.bluetoothDropdownKeyboardIcon;
        if (icon.indexOf("mouse") >= 0)
            return Theme.bluetoothDropdownMouseIcon;
        if (icon.indexOf("gaming") >= 0 || icon.indexOf("joystick") >= 0)
            return Theme.bluetoothDropdownGamepadIcon;
        if (icon.indexOf("phone") >= 0)
            return Theme.bluetoothDropdownPhoneIcon;
        return Theme.bluetoothDropdownDeviceIcon;
    }

    // The status a device row shows on the right. Trust and pin are not repeated here
    function deviceStatus(device) {
        var parts = [];
        if (device.connected)
            parts.push(Theme.bluetoothDropdownConnectedText);
        else if (device.pairing)
            parts.push(Theme.bluetoothDropdownPairText);
        if (device.batteryAvailable)
            parts.push(Theme.bluetoothDropdownBatteryIcon + " " + Math.round(device.battery * 100) + "%");
        return parts.join("  ");
    }

    // ---- actions, wrapped so the menu holds no service API of its own
    function setPowered(on) {
        if (hasAdapter)
            adapter.enabled = on;
    }

    function setPairable(on) {
        if (hasAdapter)
            adapter.pairable = on;
    }

    function setDiscoverable(on) {
        if (hasAdapter)
            adapter.discoverable = on;
    }

    // Discovery is what fills the found list; it is the same switch bluetoothctl calls `scan on`.
    function setScanning(on) {
        if (hasAdapter)
            adapter.discovering = on;
    }

    function connect(device) {
        if (device.connected)
            device.disconnect();
        else
            device.connect();
    }

    function setTrusted(device, on) {
        device.trusted = on;
    }

    // Pairing a device the adapter has found; the service flips `paired` when BlueZ agrees.
    function pair(device) {
        device.pair();
    }

    // Drops the pairing and the keys with it.
    function forget(device) {
        if (isPinned(device.address))
            togglePin(device.address);
        device.forget();
    }

    // The bar readout: the bluetooth glyph, crossed out when the radio is off, plus how many
    // devices are connected. Empty string when there is no adapter at all.
    readonly property string barTxt: {
        if (!hasAdapter)
            return "";
        var glyph = powered ? Theme.bluetoothDropdownIcon : Theme.bluetoothDropdownOffIcon;
        var connected = devices.filter(d => d.connected).length;
        return glyph + (connected > 0 ? " " + connected : "");
    }
}
