import Quickshell
import Quickshell.Io
import QtQuick

import "OSDs"
import "components"
import "menus"
import "root:/modules"

ShellRoot {
    // IPCs for every menu
    IpcHandler {
        target: "applauncher"
        function toggle() {
            ApplauncherState.toggle();
        }
    }

    IpcHandler {
        target: "powerdropdown"
        function toggle() {
            PowerDropdownState.toggle();
        }
    }

    IpcHandler {
        target: "volumedropdown"
        function toggle() {
            VolumeDropdownState.toggle();
        }
    }

    IpcHandler {
        target: "networkdropdown"
        function toggle() {
            NetworkMenuState.toggle();
        }
    }

    IpcHandler {
        target: "bluetoothdropdown"
        function toggle() {
            BluetoothMenuState.toggle();
        }
    }

    RefreshTimer {}

    // Taskbar
    TaskBar {}
    Border {}

    // OSDs
    VolumeOSD {}

    // Menus, built on demand: a closed menu holds no layer surface.
    // `alive` is written only from the handlers below, never derived from the open state:
    // deriving it makes it go false in the same instant the state does, which destroys the
    // window before it can animate out. Closing starts the timer, the timer drops the window.
    property bool launcherAlive: false
    property bool powerAlive: false
    property bool volumeAlive: false
    property bool networkAlive: false
    property bool bluetoothAlive: false

    LazyLoader {
        id: launcherLoader
        active: launcherAlive
        AppLauncher {}
    }
    Timer {
        id: launcherUnload
        interval: Theme.appLauncherHeightAnimDuration + Theme.menuUnloadGrace
        onTriggered: launcherAlive = false
    }
    Connections {
        target: ApplauncherState
        function onLauncherVisibleChanged() {
            if (ApplauncherState.launcherVisible) {
                launcherUnload.stop();
                launcherAlive = true;
            } else {
                launcherUnload.start();
            }
        }
    }

    LazyLoader {
        id: powerLoader
        active: powerAlive
        PowerDropdown {}
    }
    Timer {
        id: powerUnload
        interval: Theme.powerDropdownAnimDuration + Theme.menuUnloadGrace
        onTriggered: powerAlive = false
    }
    Connections {
        target: PowerDropdownState
        function onVisibleChanged() {
            if (PowerDropdownState.visible) {
                powerUnload.stop();
                powerAlive = true;
            } else {
                powerUnload.start();
            }
        }
    }

    LazyLoader {
        id: volumeLoader
        active: volumeAlive
        VolumeDropdown {}
    }
    Timer {
        id: volumeUnload
        interval: Theme.volumeDropdownAnimDuration + Theme.menuUnloadGrace
        onTriggered: volumeAlive = false
    }
    Connections {
        target: VolumeDropdownState
        function onVisibleChanged() {
            if (VolumeDropdownState.visible) {
                volumeUnload.stop();
                volumeAlive = true;
            } else {
                volumeUnload.start();
            }
        }
    }

    LazyLoader {
        id: bluetoothLoader
        active: bluetoothAlive
        BluetoothDropdown {}
    }
    Timer {
        id: bluetoothUnload
        interval: Theme.bluetoothDropdownAnimDuration + Theme.menuUnloadGrace
        onTriggered: bluetoothAlive = false
    }
    Connections {
        target: BluetoothMenuState
        function onVisibleChanged() {
            if (BluetoothMenuState.visible) {
                bluetoothUnload.stop();
                bluetoothAlive = true;
            } else {
                bluetoothUnload.start();
            }
        }
    }

    LazyLoader {
        id: networkLoader
        active: networkAlive
        NetworkDropdown {}
    }
    Timer {
        id: networkUnload
        interval: Theme.networkDropdownAnimDuration + Theme.menuUnloadGrace
        onTriggered: networkAlive = false
    }
    Connections {
        target: NetworkMenuState
        function onVisibleChanged() {
            if (NetworkMenuState.visible) {
                networkUnload.stop();
                networkAlive = true;
            } else {
                networkUnload.start();
            }
        }
    }
}
