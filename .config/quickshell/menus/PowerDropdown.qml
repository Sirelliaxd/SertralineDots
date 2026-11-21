import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

import "root:/"
import "root:/modules"

// Power menu
// NOTE: Artix has no systemd; every action goes through loginctl.
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: PowerDropdownState.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-power-dropdown"

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
        item: PowerDropdownState.visible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    readonly property var entries: [
        {
            label: "logout",
            icon: "\uf08b",
            command: ["sh", "-c", "loginctl terminate-session \"$XDG_SESSION_ID\""]
        },
        {
            label: "suspend",
            icon: "\uf186",
            command: ["loginctl", "suspend"]
        },
        {
            label: "hibernate",
            icon: "\uf236",
            command: ["loginctl", "hibernate"]
        },
        {
            label: "reboot",
            icon: "\uf021",
            command: ["loginctl", "reboot"]
        },
        {
            label: "shutdown",
            icon: "\uf011",
            command: ["loginctl", "poweroff"]
        }
    ]

    property int selectedIndex: 0

    readonly property int panelW: Theme.powerDropdownPanelWidth
    readonly property int panelH: Theme.powerDropdownContentMargin * 2 + entries.length * Theme.powerDropdownItemHeight

    function activate(index) {
        if (index < 0 || index >= entries.length)
            return;

        Quickshell.execDetached(entries[index].command);
        PowerDropdownState.hide();
    }

    function move(delta) {
        selectedIndex = (selectedIndex + delta + entries.length) % entries.length;
    }

    Connections {
        target: PowerDropdownState

        function onVisibleChanged() {
            if (PowerDropdownState.visible)
                root.onOpened();
        }
    }

    // The window is built when it opens, so it also has to set itself up here
    Component.onCompleted: {
        if (PowerDropdownState.visible)
            root.onOpened();
    }

    function onOpened() {
        selectedIndex = 0;
        Qt.callLater(panel.forceActiveFocus);
    }

    MouseArea {
        anchors.fill: parent
        enabled: PowerDropdownState.visible
        onClicked: PowerDropdownState.hide()
    }

    Item {
        id: panel
        anchors {
            top: parent.top
            left: parent.left
            topMargin: Theme.powerDropdownMargin
            leftMargin: Theme.powerDropdownMargin
        }

        property bool shown: false
        Component.onCompleted: shown = true
        width: PowerDropdownState.visible && panel.shown ? root.panelW : 0
        height: PowerDropdownState.visible && panel.shown ? root.panelH : 0
        clip: true
        focus: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.powerDropdownAnimDuration
                easing.type: Theme.powerDropdownAnimType
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Theme.powerDropdownAnimDuration
                easing.type: Theme.powerDropdownAnimType
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Up) {
                root.move(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.move(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.activate(root.selectedIndex);
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                PowerDropdownState.hide();
                event.accepted = true;
            }
        }

        // Full size content, so nothing reflows while the panel resizes
        Item {
            width: root.panelW
            height: root.panelH

            Rectangle {
                anchors.fill: parent
                radius: Theme.powerDropdownRadius
                color: Theme.background
            }

            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.powerDropdownContentMargin
                }

                Repeater {
                    model: root.entries

                    delegate: Item {
                        id: row
                        width: parent.width
                        height: Theme.powerDropdownItemHeight

                        readonly property bool sel: root.selectedIndex === index

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.powerDropdownItemRadius
                            color: row.sel ? Theme.background : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                            spacing: 10

                            Rectangle {
                                width: Theme.powerDropdownIconBubbleSize
                                height: Theme.powerDropdownIconBubbleSize
                                radius: Theme.powerDropdownIconBubbleRadius
                                anchors.verticalCenter: parent.verticalCenter
                                color: row.sel ? Theme.foreground : Theme.foregroundTransparent
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    color: row.sel ? Theme.background : Theme.foreground
                                    font {
                                        family: Theme.fontFamily
                                        pixelSize: Theme.powerDropdownIconSize
                                    }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: row.sel ? Theme.foreground : Theme.inactive
                                font {
                                    family: Theme.fontFamily
                                    pixelSize: Theme.powerDropdownFontSize
                                    bold: row.sel
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = index
                            onClicked: root.activate(index)
                        }
                    }
                }
            }
        }
    }
}
