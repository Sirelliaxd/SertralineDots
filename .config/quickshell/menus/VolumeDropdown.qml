import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick

import "root:/"
import "root:/modules"
import "root:/components"

// Volume menu: output and input
// levels, the default output and input device, and one slider per playing stream.
// Everything is Pipewire through Quickshell (! no wpctl or pactl involved)
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: VolumeDropdownState.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-volume-dropdown"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Only take input while open, and only the panel is clickable; a click anywhere
    // else closes the menu.
    mask: Region {
        item: VolumeDropdownState.visible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    // Every node the menu can draw
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream && n.isSink && n.audio)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool sinkReady: !!sink && sink.ready && !!sink.audio
    readonly property bool sourceReady: !!source && source.ready && !!source.audio

    readonly property int panelW: Theme.volumeDropdownPanelWidth

    // Sampled from the singleton. Bound
    // until the first open, so the window's very first frame already has the right value.
    property real anchorX: VolumeDropdownState.anchorX

    // 0 none, 1 the sink list, 2 the source list. One list at a time keeps the panel short.
    property int openList: 0
    property bool streamsShown: false

    function setSinkVolume(level) {
        if (sinkReady)
            sink.audio.volume = level;
    }
    function setSourceVolume(level) {
        if (sourceReady)
            source.audio.volume = level;
    }
    function pickSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
        openList = 0;
        selectedKey = "out-device";
    }
    function pickSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
        openList = 0;
        selectedKey = "in-device";
    }
    function label(node) {
        return node.properties["application.name"] || node.description || node.name;
    }

    // Keyboard selection.
    property string selectedKey: "out-level"

    readonly property var navRows: {
        var rows = ["out-level", "out-device"];
        var i;
        if (openList === 1)
            for (i = 0; i < sinks.length; i++)
                rows.push("out-entry-" + sinks[i].id);
        rows.push("in-level");
        rows.push("in-device");
        if (openList === 2)
            for (i = 0; i < sources.length; i++)
                rows.push("in-entry-" + sources[i].id);
        rows.push("apps");
        if (streamsShown)
            for (i = 0; i < streams.length; i++)
                rows.push("stream-" + streams[i].id);
        return rows;
    }

    function keyKind(key) {
        if (key === "apps")
            return "apps";
        if (key.indexOf("-entry-") !== -1)
            return "entry";
        if (key.indexOf("-level") !== -1)
            return "level";
        if (key.indexOf("-device") !== -1)
            return "device";
        return "stream";
    }

    function nodeOf(key) {
        var id = parseInt(key.substring(key.lastIndexOf("-") + 1));
        var list = streams.concat(sinks, sources);
        for (var i = 0; i < list.length; i++)
            if (list[i].id === id)
                return list[i];
        return null;
    }

    // The node a key mutes or nudges: a level row, or one stream.
    function levelNode(key) {
        var kind = keyKind(key);
        if (kind === "level")
            return key === "out-level" ? sink : source;
        if (kind === "stream")
            return nodeOf(key);
        return null;
    }

    function toggleMute(key) {
        var node = levelNode(key);
        if (node && node.audio)
            node.audio.muted = !node.audio.muted;
    }

    function nudge(key, delta) {
        var node = levelNode(key);
        if (!node || !node.audio)
            return;
        node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + delta));
    }

    function activate(key) {
        var kind = keyKind(key);
        if (kind === "device") {
            var which = key === "out-device" ? 1 : 2;
            openList = openList === which ? 0 : which;
        } else if (kind === "entry") {
            if (key.indexOf("out-entry-") === 0)
                pickSink(nodeOf(key));
            else
                pickSource(nodeOf(key));
        } else if (kind === "apps") {
            streamsShown = !streamsShown;
        }
    }

    function move(delta) {
        var idx = navRows.indexOf(selectedKey);
        if (idx < 0)
            idx = delta > 0 ? -1 : 0;
        selectedKey = navRows[(idx + delta + navRows.length) % navRows.length];
        Qt.callLater(root.ensureVisible);
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

    Connections {
        target: VolumeDropdownState

        function onVisibleChanged() {
            if (VolumeDropdownState.visible)
                root.onOpened();
        }
    }

    // The window is built when it opens
    Component.onCompleted: {
        if (VolumeDropdownState.visible)
            root.onOpened();
    }

    function onOpened() {
        openList = 0;
        streamsShown = false;
        selectedKey = "out-level";
        anchorX = VolumeDropdownState.anchorX;
        Qt.callLater(panel.forceActiveFocus);
    }

    MouseArea {
        anchors.fill: parent
        enabled: VolumeDropdownState.visible
        onClicked: VolumeDropdownState.hide()
    }

    // One level row: bubble, label, slider, percent readout
    component LevelRow: Item {
        id: levelRow

        property string rowKey: ""
        property string icon: ""
        property string mutedIcon: ""
        property string label: ""
        property real value: 0
        property bool ready: false
        property bool muted: false
        property bool selected: false

        signal moved(real level)
        signal muteToggled

        width: parent.width
        height: Theme.volumeDropdownRowHeight

        // Hover only moves the selection; the slider's own area sits on top of this one
        MouseArea {
            id: levelHover
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.selectedKey = levelRow.rowKey
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.volumeDropdownRowRadius
            color: levelHover.containsMouse || levelRow.selected ? Theme.background : "transparent"
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
            width: Theme.volumeDropdownIconBubbleSize
            height: Theme.volumeDropdownIconBubbleSize
            radius: Theme.volumeDropdownIconBubbleRadius
            color: levelRow.muted ? Theme.foreground : Theme.foregroundTransparent
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                anchors.centerIn: parent
                text: levelRow.muted ? levelRow.mutedIcon : levelRow.icon
                color: levelRow.muted ? Theme.background : Theme.foreground
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.volumeDropdownIconSize
                }
            }

            // The bubble is the mute button
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: levelRow.muteToggled()
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.volumeDropdownIconBubbleSize + 10
                verticalCenter: parent.verticalCenter
            }
            width: Theme.volumeDropdownLabelWidth
            text: levelRow.label
            color: Theme.foreground
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownFontSize
            }
        }

        VolumeSlider {
            anchors {
                left: parent.left
                leftMargin: Theme.volumeDropdownIconBubbleSize + 10 + Theme.volumeDropdownLabelWidth + 10
                right: levelPct.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            value: levelRow.value
            onMoved: function (level) {
                levelRow.moved(level);
            }
        }

        Text {
            id: levelPct
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            width: Theme.volumeDropdownPercentWidth
            horizontalAlignment: Text.AlignRight
            text: levelRow.ready ? Math.round(levelRow.value * 100) + "%" : "--"
            color: Theme.volumeDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownFontSize
            }
        }
    }

    // A row that shows the current device and opens a list of the others
    component DeviceRow: Item {
        id: deviceRow

        property string rowKey: ""
        property string icon: ""
        property string label: ""
        property string value: ""
        property bool expanded: false
        property bool selected: false

        signal clicked

        width: parent.width
        height: Theme.volumeDropdownRowHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.volumeDropdownRowRadius
            color: deviceHover.containsMouse || deviceRow.expanded || deviceRow.selected ? Theme.background : "transparent"
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
            width: Theme.volumeDropdownIconBubbleSize
            height: Theme.volumeDropdownIconBubbleSize
            radius: Theme.volumeDropdownIconBubbleRadius
            color: deviceHover.containsMouse || deviceRow.expanded || deviceRow.selected ? Theme.foreground : Theme.foregroundTransparent
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                anchors.centerIn: parent
                text: deviceRow.icon
                color: deviceHover.containsMouse || deviceRow.expanded || deviceRow.selected ? Theme.background : Theme.foreground
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.volumeDropdownIconSize
                }
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.volumeDropdownIconBubbleSize + 10
                verticalCenter: parent.verticalCenter
            }
            width: Theme.volumeDropdownLabelWidth
            text: deviceRow.label
            color: Theme.foreground
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownFontSize
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.volumeDropdownIconBubbleSize + 10 + Theme.volumeDropdownLabelWidth + 10
                right: deviceChevron.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            text: deviceRow.value
            elide: Text.ElideRight
            color: Theme.volumeDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownFontSize
            }
        }

        Text {
            id: deviceChevron
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text: deviceRow.expanded ? Theme.volumeDropdownChevronOpen : Theme.volumeDropdownChevronClosed
            color: Theme.volumeDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownIconSize
            }
        }

        MouseArea {
            id: deviceHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selectedKey = deviceRow.rowKey
            onClicked: {
                root.selectedKey = deviceRow.rowKey;
                deviceRow.clicked();
            }
        }
    }

    // One device in an opened list
    component DeviceEntry: Item {
        id: deviceEntry

        property string rowKey: ""
        property var node
        property bool selected: false

        signal picked

        width: parent.width
        height: Theme.volumeDropdownDeviceRowHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.volumeDropdownRowRadius
            color: deviceEntryHover.containsMouse || deviceEntry.selected ? Theme.background : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.volumeDropdownDeviceIndent
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text: deviceEntry.node.description || deviceEntry.node.name
            elide: Text.ElideRight
            color: deviceEntry.selected ? Theme.foreground : Theme.volumeDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownFontSize
            }
        }

        MouseArea {
            id: deviceEntryHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selectedKey = deviceEntry.rowKey
            onClicked: {
                root.selectedKey = deviceEntry.rowKey;
                deviceEntry.picked();
            }
        }
    }

    // One playing stream: its name, its own level, its own mute
    component StreamRow: Item {
        id: streamRow

        property string rowKey: ""
        property var node
        property bool selected: false
        property bool muted: false

        signal moved(real level)
        signal muteToggled

        width: parent.width
        height: Theme.volumeDropdownRowHeight

        MouseArea {
            id: streamHover
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.selectedKey = streamRow.rowKey
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.volumeDropdownRowRadius
            color: streamHover.containsMouse || streamRow.selected ? Theme.background : "transparent"
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
            width: Theme.volumeDropdownIconBubbleSize
            height: Theme.volumeDropdownIconBubbleSize
            radius: Theme.volumeDropdownIconBubbleRadius
            color: streamRow.muted ? Theme.foreground : Theme.foregroundTransparent
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                anchors.centerIn: parent
                text: streamRow.muted ? Theme.volumeDropdownOutputMutedIcon : Theme.volumeDropdownStreamsIcon
                color: streamRow.muted ? Theme.background : Theme.foreground
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.volumeDropdownIconSize
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: streamRow.muteToggled()
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: Theme.volumeDropdownIconBubbleSize + 10
                right: streamSlider.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            text: root.label(streamRow.node)
            elide: Text.ElideRight
            color: Theme.foreground
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownFontSize
            }
        }

        VolumeSlider {
            id: streamSlider
            anchors {
                right: streamPct.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            width: Theme.volumeDropdownStreamSliderWidth
            value: streamRow.node.audio ? streamRow.node.audio.volume : 0
            onMoved: function (level) {
                streamRow.moved(level);
            }
        }

        Text {
            id: streamPct
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            width: Theme.volumeDropdownPercentWidth
            horizontalAlignment: Text.AlignRight
            text: streamRow.node.audio ? Math.round(streamRow.node.audio.volume * 100) + "%" : "--"
            color: Theme.volumeDropdownDimColor
            font {
                family: Theme.fontFamily
                pixelSize: Theme.volumeDropdownFontSize
            }
        }
    }

    Item {
        id: panel
        anchors {
            top: parent.top
            left: parent.left
            topMargin: Theme.volumeDropdownMargin
            leftMargin: Math.max(Theme.volumeDropdownMargin, Math.min(root.anchorX - panel.width / 2, root.width - panel.width - Theme.volumeDropdownMargin))
        }

        property bool shown: false
        Component.onCompleted: shown = true
        width: VolumeDropdownState.visible && panel.shown ? root.panelW : 0
        height: VolumeDropdownState.visible && panel.shown ? flick.height + 2 * Theme.volumeDropdownContentMargin : 0
        clip: true
        focus: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.volumeDropdownAnimDuration
                easing.type: Theme.volumeDropdownAnimType
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: Theme.volumeDropdownAnimDuration
                easing.type: Theme.volumeDropdownAnimType
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                VolumeDropdownState.hide();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.move(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.move(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                root.nudge(root.selectedKey, -Theme.volumeDropdownKeyStep);
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                root.nudge(root.selectedKey, Theme.volumeDropdownKeyStep);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                root.activate(root.selectedKey);
                event.accepted = true;
            } else if (event.key === Qt.Key_M) {
                root.toggleMute(root.selectedKey);
                event.accepted = true;
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.volumeDropdownRadius
            color: Theme.background
        }

        Flickable {
            id: flick
            x: Theme.volumeDropdownContentMargin
            y: Theme.volumeDropdownContentMargin
            width: root.panelW - 2 * Theme.volumeDropdownContentMargin
            height: Math.min(content.implicitHeight, Theme.volumeDropdownMaxContentHeight)
            contentWidth: width
            contentHeight: content.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: content
                width: flick.width
                spacing: 0

                LevelRow {
                    rowKey: "out-level"
                    icon: Theme.volumeDropdownOutputIcon
                    mutedIcon: Theme.volumeDropdownOutputMutedIcon
                    label: Theme.volumeDropdownOutputText
                    value: root.sinkReady ? root.sink.audio.volume : 0
                    ready: root.sinkReady
                    muted: root.sinkReady && root.sink.audio.muted
                    selected: root.selectedKey === "out-level"
                    onMoved: function (level) {
                        root.setSinkVolume(level);
                    }
                    onMuteToggled: root.toggleMute(rowKey)
                }

                DeviceRow {
                    rowKey: "out-device"
                    icon: Theme.volumeDropdownDeviceIcon
                    label: Theme.volumeDropdownOutputText
                    value: root.sink ? root.sink.description : ""
                    expanded: root.openList === 1
                    selected: root.selectedKey === "out-device"
                    onClicked: root.openList = root.openList === 1 ? 0 : 1
                }

                Repeater {
                    model: root.openList === 1 ? root.sinks : []

                    delegate: DeviceEntry {
                        rowKey: "out-entry-" + modelData.id
                        node: modelData
                        selected: modelData === root.sink
                        onPicked: root.pickSink(modelData)
                    }
                }

                LevelRow {
                    rowKey: "in-level"
                    icon: Theme.volumeDropdownInputIcon
                    mutedIcon: Theme.volumeDropdownInputMutedIcon
                    label: Theme.volumeDropdownInputText
                    value: root.sourceReady ? root.source.audio.volume : 0
                    ready: root.sourceReady
                    muted: root.sourceReady && root.source.audio.muted
                    selected: root.selectedKey === "in-level"
                    onMoved: function (level) {
                        root.setSourceVolume(level);
                    }
                    onMuteToggled: root.toggleMute(rowKey)
                }

                DeviceRow {
                    rowKey: "in-device"
                    icon: Theme.volumeDropdownDeviceIcon
                    label: Theme.volumeDropdownInputText
                    value: root.source ? root.source.description : ""
                    expanded: root.openList === 2
                    selected: root.selectedKey === "in-device"
                    onClicked: root.openList = root.openList === 2 ? 0 : 2
                }

                Repeater {
                    model: root.openList === 2 ? root.sources : []

                    delegate: DeviceEntry {
                        rowKey: "in-entry-" + modelData.id
                        node: modelData
                        selected: modelData === root.source
                        onPicked: root.pickSource(modelData)
                    }
                }

                // Show or hide the per-stream sliders
                Item {
                    id: appsRow
                    property string rowKey: "apps"

                    width: parent.width
                    height: Theme.volumeDropdownRowHeight

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.volumeDropdownRowRadius
                        color: appsHover.containsMouse || root.streamsShown || root.selectedKey === "apps" ? Theme.background : "transparent"
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
                        width: Theme.volumeDropdownIconBubbleSize
                        height: Theme.volumeDropdownIconBubbleSize
                        radius: Theme.volumeDropdownIconBubbleRadius
                        color: appsHover.containsMouse || root.streamsShown || root.selectedKey === "apps" ? Theme.foreground : Theme.foregroundTransparent
                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Theme.volumeDropdownStreamsIcon
                            color: appsHover.containsMouse || root.streamsShown || root.selectedKey === "apps" ? Theme.background : Theme.foreground
                            font {
                                family: Theme.fontFamily
                                pixelSize: Theme.volumeDropdownIconSize
                            }
                        }
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.volumeDropdownIconBubbleSize + 10
                            verticalCenter: parent.verticalCenter
                        }
                        text: Theme.volumeDropdownStreamsText
                        color: Theme.foreground
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.volumeDropdownFontSize
                        }
                    }

                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        text: root.streamsShown ? Theme.volumeDropdownChevronOpen : Theme.volumeDropdownChevronClosed
                        color: Theme.volumeDropdownDimColor
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.volumeDropdownIconSize
                        }
                    }

                    MouseArea {
                        id: appsHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectedKey = "apps"
                        onClicked: {
                            root.selectedKey = "apps";
                            root.streamsShown = !root.streamsShown;
                        }
                    }
                }

                Repeater {
                    model: root.streamsShown ? root.streams : []

                    delegate: StreamRow {
                        rowKey: "stream-" + modelData.id
                        node: modelData
                        selected: root.selectedKey === rowKey
                        muted: modelData.audio ? modelData.audio.muted : false
                        onMoved: function (level) {
                            if (modelData.audio)
                                modelData.audio.volume = level;
                        }
                        onMuteToggled: root.toggleMute(rowKey)
                    }
                }

                // Nothing is playing
                Item {
                    visible: root.streamsShown && root.streams.length === 0
                    width: parent.width
                    height: Theme.volumeDropdownDeviceRowHeight

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.volumeDropdownDeviceIndent
                            verticalCenter: parent.verticalCenter
                        }
                        text: Theme.volumeDropdownNoStreamsText
                        color: Theme.volumeDropdownDimColor
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.volumeDropdownFontSize
                        }
                    }
                }
            }
        }
    }
}
