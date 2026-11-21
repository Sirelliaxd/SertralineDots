import Quickshell
import Quickshell.Wayland
import QtQuick

import "root:/"
import "root:/modules"
import "root:/components"

// Bluetooth menu, opened from the bluetooth readout in the bar's right end: the adapter and
// what it calls itself, its power, pairing and discovery switches, the discovery list, and
// every paired device with connect, trust, pin and forget. The data comes from BlueInfo, which
// binds straight to Quickshell's Bluetooth service
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: BluetoothMenuState.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-bluetooth-dropdown"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusiveZone: 0

    // Only take input while open, and only the panel is clickable; a click anywhere
    // else closes the menu.
    mask: Region {
        item: BluetoothMenuState.visible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    // Sampled from the singleton when the menu opens, and frozen there, so the panel does not
    // follow the bar's text widths while it is up. Bound until the first open.
    property real anchorX: BluetoothMenuState.anchorX

    readonly property int panelW: Theme.bluetoothDropdownPanelWidth

    // One list open at a time, like the other menus.
    property bool scanOpen: false
    property string openDevice: ""  // address of the device whose actions are open

    property string selectedKey: "power"

    // Keyboard selection.
    readonly property var navRows: {
        var rows = ["power", "pairable", "discoverable", "scan"];
        var i;
        if (scanOpen) {
            rows.push("scan-rescan");
            for (i = 0; i < BlueInfo.found.length; i++)
                rows.push("found-" + BlueInfo.found[i].address);
        }
        for (i = 0; i < BlueInfo.paired.length; i++) {
            var address = BlueInfo.paired[i].address;
            rows.push("device-" + address);
            if (openDevice === address)
                rows.push("device-" + address + "-connect", "device-" + address + "-trust", "device-" + address + "-pin", "device-" + address + "-forget");
        }
        return rows;
    }

    function move(delta) {
        var idx = navRows.indexOf(selectedKey);
        if (idx < 0)
            idx = delta > 0 ? -1 : 0;
        selectedKey = navRows[(idx + delta + navRows.length) % navRows.length];
        Qt.callLater(root.ensureVisible);
    }

    function activate(key) {
        if (key === "power") {
            BlueInfo.setPowered(!BlueInfo.powered);
        } else if (key === "pairable") {
            BlueInfo.setPairable(!BlueInfo.pairable);
        } else if (key === "discoverable") {
            BlueInfo.setDiscoverable(!BlueInfo.discoverable);
        } else if (key === "scan") {
            scanOpen = !scanOpen;
            BlueInfo.setScanning(scanOpen);
        } else if (key === "scan-rescan") {
            BlueInfo.setScanning(false);
            BlueInfo.setScanning(true);
        } else if (key.indexOf("found-") === 0) {
            BlueInfo.pair(root.deviceOf(key.substring(6)));
        } else if (key.indexOf("device-") === 0) {
            var rest = key.substring(7);
            var suffix = rest.indexOf("-") >= 0 ? rest.substring(rest.indexOf("-") + 1) : "";
            var address = suffix === "" ? rest : rest.substring(0, rest.indexOf("-"));
            var device = root.deviceOf(address);
            if (suffix === "") {
                openDevice = openDevice === address ? "" : address;
            } else if (suffix === "connect") {
                BlueInfo.connect(device);
            } else if (suffix === "trust") {
                BlueInfo.setTrusted(device, !device.trusted);
            } else if (suffix === "pin") {
                BlueInfo.togglePin(address);
            } else if (suffix === "forget") {
                BlueInfo.forget(device);
                openDevice = "";
                selectedKey = "scan";
            }
        }
    }

    // Row keys carry the address, so the device behind one has to be looked up again
    function deviceOf(address) {
        var list = BlueInfo.devices.filter(d => d.address === address);
        return list.length > 0 ? list[0] : null;
    }

    // Keep the selected row inside the scroll area
    function ensureVisible() {
        for (var i = 0; i < content.children.length; i++) {
            var row = content.children[i];
            if (row.rowKey === undefined || row.rowKey !== selectedKey)
                continue;
            if (row.y < flick.contentY)
                flick.contentY = row.y;
            else if (row.y + row.height > flick.contentY + flick.height)
                flick.contentY = Math.min(row.y + row.height - flick.height, Math.max(0, content.implicitHeight - flick.height));
            return;
        }
    }

    // A long name would push a centred line out of the panel, so it is cut with an ellipsis
    function clip(text, max) {
        if (!text)
            return "";
        return text.length > max ? text.substring(0, max - 1) + "\u2026" : text;
    }

    Connections {
        target: BluetoothMenuState

        function onVisibleChanged() {
            if (BluetoothMenuState.visible)
                root.onOpened();
        }
    }

    // The window is built when it opens
    Component.onCompleted: {
        if (BluetoothMenuState.visible)
            root.onOpened();
    }

    // Discovery only runs while the menu is up: nothing scans for devices in the background
    Component.onDestruction: BlueInfo.setScanning(false)

    function onOpened() {
        scanOpen = false;
        openDevice = "";
        selectedKey = "power";
        anchorX = BluetoothMenuState.anchorX;
        Qt.callLater(panel.forceActiveFocus);
    }

    MouseArea {
        anchors.fill: parent
        enabled: BluetoothMenuState.visible
        onClicked: BluetoothMenuState.hide()
    }

    // A read-only row: bubble, label, value
    component ActionRow: Item {
        id: actionRow

        property string rowKey: ""
        property string icon: ""
        property string label: ""
        property string value: ""
        property bool highlight: false
        property bool selected: false
        property color iconColor: Theme.foreground

        signal clicked

        width: parent.width
        height: Theme.bluetoothDropdownRowHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.bluetoothDropdownRowRadius
            color: actionHover.containsMouse || actionRow.selected ? Theme.background : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: Theme.bluetoothDropdownIconBubbleSize
            height: Theme.bluetoothDropdownIconBubbleSize
            radius: Theme.bluetoothDropdownIconBubbleRadius
            color: actionRow.highlight ? Theme.foreground : Theme.foregroundTransparent
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                anchors.centerIn: parent
                text: actionRow.icon
                color: actionRow.highlight ? Theme.background : actionRow.iconColor
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.bluetoothDropdownIconSize
                }
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.bluetoothDropdownIconBubbleSize + 10
                verticalCenter: parent.verticalCenter
            }
            width: Theme.bluetoothDropdownLabelWidth
            text: actionRow.label
            elide: Text.ElideRight
            color: Theme.foreground
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownFontSize
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.bluetoothDropdownIconBubbleSize + 10 + Theme.bluetoothDropdownLabelWidth + 10
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text: actionRow.value
            elide: Text.ElideRight
            color: Theme.bluetoothDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownFontSize
            }
        }

        MouseArea {
            id: actionHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selectedKey = actionRow.rowKey
            onClicked: {
                root.selectedKey = actionRow.rowKey;
                actionRow.clicked();
            }
        }
    }

    // An ActionRow that flips a state when clicked
    component ToggleRow: ActionRow {
        signal toggled

        onClicked: toggled()
    }

    // An ActionRow with a chevron: it opens a list under itself
    component ListRow: Item {
        id: listRow

        property string rowKey: ""
        property string icon: ""
        property string label: ""
        property string value: ""
        property bool expanded: false
        property bool selected: false
        property bool highlight: false
        property bool labelBold: false
        property int labelSize: Theme.bluetoothDropdownFontSize
        property int labelWidth: Theme.bluetoothDropdownLabelWidth
        property string badge: ""
        property color badgeColor: Theme.foreground

        signal clicked

        width: parent.width
        height: Theme.bluetoothDropdownRowHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.bluetoothDropdownRowRadius
            color: listHover.containsMouse || listRow.expanded || listRow.selected || listRow.highlight ? Theme.background : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: Theme.bluetoothDropdownIconBubbleSize
            height: Theme.bluetoothDropdownIconBubbleSize
            radius: Theme.bluetoothDropdownIconBubbleRadius
            color: listHover.containsMouse || listRow.expanded || listRow.selected || listRow.highlight ? Theme.foreground : Theme.foregroundTransparent
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                anchors.centerIn: parent
                text: listRow.icon
                color: listHover.containsMouse || listRow.expanded || listRow.selected || listRow.highlight ? Theme.background : Theme.foreground
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.bluetoothDropdownIconSize
                }
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.bluetoothDropdownIconBubbleSize + 10
                verticalCenter: parent.verticalCenter
            }
            width: listRow.labelWidth
            text: listRow.label
            elide: Text.ElideRight
            color: Theme.foreground
            font {
                family: Theme.fontFamily
                pixelSize: listRow.labelSize
                bold: listRow.labelBold
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.bluetoothDropdownIconBubbleSize + 10 + listRow.labelWidth + 10
                right: listChevron.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            text: listRow.value
            elide: Text.ElideRight
            color: Theme.bluetoothDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownFontSize
            }
        }

        Text {
            visible: listRow.badge !== ""
            anchors {
                right: listChevron.left
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text: listRow.badge
            color: listRow.badgeColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownIconSize
            }
        }

        Text {
            id: listChevron
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text: listRow.expanded ? Theme.bluetoothDropdownChevronOpen : Theme.bluetoothDropdownChevronClosed
            color: Theme.bluetoothDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownIconSize
            }
        }

        MouseArea {
            id: listHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selectedKey = listRow.rowKey
            onClicked: {
                root.selectedKey = listRow.rowKey;
                listRow.clicked();
            }
        }
    }

    // One entry inside an opened list
    component EntryRow: Item {
        id: entryRow

        property string rowKey: ""
        property string text: ""
        property string value: ""
        property bool active: false
        property bool selected: false

        signal clicked

        // children of a dropdown
        x: Theme.bluetoothDropdownChildIndent
        width: parent.width - 2 * Theme.bluetoothDropdownChildIndent
        height: Theme.bluetoothDropdownEntryRowHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.bluetoothDropdownRowRadius
            color: entryHover.containsMouse || entryRow.selected ? Theme.background : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.bluetoothDropdownEntryIndent - Theme.bluetoothDropdownChildIndent
                right: entryValue.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            text: entryRow.text
            elide: Text.ElideRight
            color: entryRow.active ? Theme.foreground : Theme.bluetoothDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownFontSize
                bold: entryRow.active
            }
        }

        Text {
            id: entryValue
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text: entryRow.value
            color: Theme.bluetoothDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownFontSize
            }
        }

        MouseArea {
            id: entryHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selectedKey = entryRow.rowKey
            onClicked: {
                root.selectedKey = entryRow.rowKey;
                entryRow.clicked();
            }
        }
    }

    // A dim line for an empty list
    component EmptyRow: Item {
        id: emptyRow

        property string text: ""

        width: parent.width
        height: Theme.bluetoothDropdownEntryRowHeight

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.bluetoothDropdownEntryIndent
                verticalCenter: parent.verticalCenter
            }
            text: emptyRow.text
            color: Theme.bluetoothDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.bluetoothDropdownFontSize
            }
        }
    }

    // One cell of the info group
    component StatCell: Item {
        id: statCell

        property string icon: ""
        property string label: ""
        property string value: ""

        width: infoGrid.cellW
        height: Theme.bluetoothDropdownStatHeight

        Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: Theme.bluetoothDropdownIconBubbleSize
            height: Theme.bluetoothDropdownIconBubbleSize
            radius: Theme.bluetoothDropdownIconBubbleRadius
            color: Theme.foregroundTransparent

            Text {
                anchors.centerIn: parent
                text: statCell.icon
                color: Theme.foreground
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.bluetoothDropdownIconSize
                }
            }
        }

        Column {
            anchors {
                left: parent.left
                leftMargin: Theme.bluetoothDropdownIconBubbleSize + 10
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: 3

            Text {
                width: parent.width
                text: statCell.label
                elide: Text.ElideRight
                color: Theme.bluetoothDropdownDimColor
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.bluetoothDropdownLabelSize
                }
            }

            Text {
                width: parent.width
                text: statCell.value
                elide: Text.ElideRight
                color: Theme.foreground
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.bluetoothDropdownFontSize
                }
            }
        }
    }

    Item {
        id: panel

        anchors.top: parent.top
        anchors.topMargin: Theme.bluetoothDropdownMargin
        x: Math.max(Theme.bluetoothDropdownMargin, Math.min(root.anchorX - panel.width / 2, root.width - panel.width - Theme.bluetoothDropdownMargin))

        property bool shown: false
        Component.onCompleted: shown = true
        width: BluetoothMenuState.visible && panel.shown ? root.panelW : 0
        height: BluetoothMenuState.visible && panel.shown ? flick.height + 2 * Theme.bluetoothDropdownContentMargin : 0
        clip: true
        focus: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.bluetoothDropdownAnimDuration
                easing.type: Theme.bluetoothDropdownAnimType
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: Theme.bluetoothDropdownAnimDuration
                easing.type: Theme.bluetoothDropdownAnimType
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                BluetoothMenuState.hide();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.move(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.move(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                root.activate(root.selectedKey);
                event.accepted = true;
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.bluetoothDropdownRadius
            color: Theme.background
        }

        // Full size content
        Flickable {
            id: flick
            x: Theme.bluetoothDropdownContentMargin
            y: Theme.bluetoothDropdownContentMargin
            width: root.panelW - 2 * Theme.bluetoothDropdownContentMargin
            height: Math.min(content.implicitHeight, Theme.bluetoothDropdownMaxContentHeight)
            contentWidth: width
            contentHeight: content.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: content
                width: flick.width
                spacing: 0

                // The adapter, centred over the block it belongs to
                Item {
                    width: parent.width
                    height: Theme.bluetoothDropdownNicHeight

                    Text {
                        anchors.centerIn: parent
                        text: BlueInfo.adapterLabel !== "" ? root.clip(BlueInfo.adapterLabel, Theme.bluetoothDropdownNameMax) : Theme.bluetoothDropdownNoAdapterText
                        color: Theme.foreground
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.bluetoothDropdownFontSize
                        }
                    }
                }

                // The adapter's four readouts share one bubble
                Item {
                    width: parent.width
                    height: infoGrid.height + 2 * Theme.bluetoothDropdownGroupPadding

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.bluetoothDropdownRowRadius
                        color: Theme.background
                    }

                    Grid {
                        id: infoGrid
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Theme.bluetoothDropdownGroupPadding
                        }
                        columns: 2
                        columnSpacing: Theme.bluetoothDropdownStatSpacing
                        rowSpacing: Theme.bluetoothDropdownStatSpacing
                        readonly property real cellW: (width - columnSpacing) / 2

                        StatCell {
                            icon: Theme.bluetoothDropdownAdapterIcon
                            label: Theme.bluetoothDropdownAdapterText
                            value: BlueInfo.adapterId !== "" ? BlueInfo.adapterId : Theme.bluetoothDropdownEmptyText
                        }

                        StatCell {
                            icon: Theme.bluetoothDropdownIcon
                            label: Theme.bluetoothDropdownAliasText
                            value: BlueInfo.adapterLabel !== "" ? BlueInfo.adapterLabel : Theme.bluetoothDropdownEmptyText
                        }

                        StatCell {
                            icon: BlueInfo.powered ? Theme.bluetoothDropdownIcon : Theme.bluetoothDropdownOffIcon
                            label: Theme.bluetoothDropdownStateText
                            value: BlueInfo.powered ? Theme.bluetoothDropdownOnText : Theme.bluetoothDropdownOffText
                        }

                        StatCell {
                            icon: Theme.bluetoothDropdownDeviceIcon
                            label: Theme.bluetoothDropdownDevicesText
                            value: BlueInfo.paired.length + ""
                        }
                    }
                }

                ToggleRow {
                    rowKey: "power"
                    icon: BlueInfo.powered ? Theme.bluetoothDropdownIcon : Theme.bluetoothDropdownOffIcon
                    label: Theme.bluetoothDropdownPowerText
                    value: BlueInfo.powered ? Theme.bluetoothDropdownOnText : Theme.bluetoothDropdownOffText
                    highlight: !BlueInfo.powered
                    selected: root.selectedKey === "power"
                    onToggled: BlueInfo.setPowered(!BlueInfo.powered)
                }

                ToggleRow {
                    rowKey: "pairable"
                    icon: Theme.bluetoothDropdownPairIcon
                    label: Theme.bluetoothDropdownPairableText
                    value: BlueInfo.pairable ? Theme.bluetoothDropdownOnText : Theme.bluetoothDropdownOffText
                    highlight: BlueInfo.pairable
                    selected: root.selectedKey === "pairable"
                    onToggled: BlueInfo.setPairable(!BlueInfo.pairable)
                }

                ToggleRow {
                    rowKey: "discoverable"
                    icon: Theme.bluetoothDropdownAdapterIcon
                    label: Theme.bluetoothDropdownDiscoverableText
                    value: BlueInfo.discoverable ? Theme.bluetoothDropdownOnText : Theme.bluetoothDropdownOffText
                    highlight: BlueInfo.discoverable
                    selected: root.selectedKey === "discoverable"
                    onToggled: BlueInfo.setDiscoverable(!BlueInfo.discoverable)
                }

                ListRow {
                    rowKey: "scan"
                    icon: Theme.bluetoothDropdownScanIcon
                    label: Theme.bluetoothDropdownScanText
                    value: BlueInfo.found.length + ""
                    expanded: root.scanOpen
                    highlight: BlueInfo.scanning
                    selected: root.selectedKey === "scan"
                    onClicked: {
                        root.scanOpen = !root.scanOpen;
                        BlueInfo.setScanning(root.scanOpen);
                    }
                }

                EntryRow {
                    visible: root.scanOpen
                    rowKey: "scan-rescan"
                    text: Theme.bluetoothDropdownRescanText
                    selected: root.selectedKey === "scan-rescan"
                    onClicked: {
                        BlueInfo.setScanning(false);
                        BlueInfo.setScanning(true);
                    }
                }

                Repeater {
                    model: root.scanOpen ? BlueInfo.found : []

                    delegate: EntryRow {
                        rowKey: "found-" + modelData.address
                        text: BlueInfo.deviceLabel(modelData)
                        value: modelData.pairing ? Theme.bluetoothDropdownPairText : Theme.bluetoothDropdownPairIcon
                        selected: root.selectedKey === rowKey
                        onClicked: BlueInfo.pair(modelData)
                    }
                }

                EmptyRow {
                    visible: root.scanOpen && BlueInfo.found.length === 0
                    text: Theme.bluetoothDropdownNoneFoundText
                }

                // Divider between the switches and the devices
                Item {
                    width: parent.width
                    height: Theme.bluetoothDropdownSeparatorMargin * 2 + 1

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        height: 1
                        color: Theme.bluetoothDropdownSeparatorColor
                    }
                }

                // Section heading
                Item {
                    width: parent.width
                    height: Theme.bluetoothDropdownEntryRowHeight

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.bluetoothDropdownEntryIndent
                            verticalCenter: parent.verticalCenter
                        }
                        text: Theme.bluetoothDropdownPairedText
                        color: Theme.bluetoothDropdownDimColor
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.bluetoothDropdownLabelSize
                            bold: true
                        }
                    }

                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        text: BlueInfo.paired.length + ""
                        color: Theme.bluetoothDropdownDimColor
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.bluetoothDropdownLabelSize
                        }
                    }
                }

                Repeater {
                    model: BlueInfo.paired

                    // Row and actions together
                    delegate: Item {
                        id: deviceBlock

                        property string rowKey: "device-" + modelData.address
                        property bool opened: root.openDevice === modelData.address

                        // children of the devices section
                        x: Theme.bluetoothDropdownChildIndent
                        width: parent.width - 2 * Theme.bluetoothDropdownChildIndent
                        height: deviceColumn.height

                        Column {
                            id: deviceColumn
                            width: parent.width

                            ListRow {
                                rowKey: deviceBlock.rowKey
                                icon: BlueInfo.deviceIcon(modelData)
                                label: BlueInfo.deviceLabel(modelData)
                                labelBold: true
                                labelSize: Theme.bluetoothDropdownDeviceNameSize
                                labelWidth: Theme.bluetoothDropdownDeviceLabelWidth
                                badge: BlueInfo.isPinned(modelData.address) ? Theme.bluetoothDropdownPinIcon : ""
                                badgeColor: Theme.bluetoothDropdownPinnedColor
                                value: BlueInfo.deviceStatus(modelData)
                                expanded: deviceBlock.opened
                                highlight: modelData.connected
                                selected: root.selectedKey === deviceBlock.rowKey
                                onClicked: root.openDevice = deviceBlock.opened ? "" : modelData.address
                            }

                            // The actions for this device
                            Column {
                                width: parent.width
                                visible: deviceBlock.opened
                                topPadding: 2
                                bottomPadding: 4

                                ActionRow {
                                    x: Theme.bluetoothDropdownChildIndent
                                    width: parent.width - Theme.bluetoothDropdownChildIndent
                                    rowKey: deviceBlock.rowKey + "-connect"
                                    icon: modelData.connected ? Theme.bluetoothDropdownDisconnectIcon : Theme.bluetoothDropdownConnectIcon
                                    label: modelData.connected ? Theme.bluetoothDropdownDisconnectText : Theme.bluetoothDropdownConnectText
                                    selected: root.selectedKey === rowKey
                                    onClicked: BlueInfo.connect(modelData)
                                }

                                ActionRow {
                                    x: Theme.bluetoothDropdownChildIndent
                                    width: parent.width - Theme.bluetoothDropdownChildIndent
                                    rowKey: deviceBlock.rowKey + "-trust"
                                    icon: Theme.bluetoothDropdownTrustIcon
                                    label: modelData.trusted ? Theme.bluetoothDropdownUntrustText : Theme.bluetoothDropdownTrustText
                                    selected: root.selectedKey === rowKey
                                    onClicked: BlueInfo.setTrusted(modelData, !modelData.trusted)
                                }

                                ActionRow {
                                    x: Theme.bluetoothDropdownChildIndent
                                    width: parent.width - Theme.bluetoothDropdownChildIndent
                                    rowKey: deviceBlock.rowKey + "-pin"
                                    icon: BlueInfo.isPinned(modelData.address) ? Theme.bluetoothDropdownUnpinIcon : Theme.bluetoothDropdownPinIcon
                                    iconColor: BlueInfo.isPinned(modelData.address) ? Theme.bluetoothDropdownPinnedColor : Theme.foreground
                                    label: BlueInfo.isPinned(modelData.address) ? Theme.bluetoothDropdownUnpinText : Theme.bluetoothDropdownPinText
                                    selected: root.selectedKey === rowKey
                                    onClicked: BlueInfo.togglePin(modelData.address)
                                }

                                ActionRow {
                                    x: Theme.bluetoothDropdownChildIndent
                                    width: parent.width - Theme.bluetoothDropdownChildIndent
                                    rowKey: deviceBlock.rowKey + "-forget"
                                    icon: Theme.bluetoothDropdownForgetIcon
                                    label: Theme.bluetoothDropdownForgetText
                                    selected: root.selectedKey === rowKey
                                    onClicked: {
                                        BlueInfo.forget(modelData);
                                        root.openDevice = "";
                                    }
                                }
                            }
                        }
                    }
                }

                EmptyRow {
                    visible: BlueInfo.paired.length === 0
                    text: BlueInfo.hasAdapter ? Theme.bluetoothDropdownNoDevicesText : Theme.bluetoothDropdownNoAdapterText
                }
            }
        }
    }
}
