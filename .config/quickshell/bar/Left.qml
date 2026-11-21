import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "root:/"
import "root:/modules"

RowLayout {  // Left
    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 10
    }

    spacing: 15

    Text {  // power menu
        text: Theme.powerDropdownIcon
        color: Theme.foreground
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
            bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PowerDropdownState.toggle()
        }
    }

    Repeater {  // Workspaces
        model: 7

        BarText {
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            text: isActive ? "" : (ws ? "" : "")

            MouseArea { // Click to switch workspace
                anchors.fill: parent
                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = "${index + 1}" })`)
            }
        }
    }
}
