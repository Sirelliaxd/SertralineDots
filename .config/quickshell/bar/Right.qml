import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/"
import "root:/modules"

RowLayout {  // Right
    property alias volumeWidget: volumeTxt
    property alias networkWidget: networkTxt
    property alias btWidget: btTxt

    anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
        rightMargin: 10
    }

    spacing: 15

    IpadButton {} // OdSender ( ipad screen )
    BarText { // Network, click toggles the network menu
        id: networkTxt
        text: NetworkProc.barTxt

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: NetworkMenuState.toggle()
        }
    }
    BarText { // Bluetooth, click toggles the bluetooth menu
        id: btTxt
        text: BlueInfo.barTxt

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: BluetoothMenuState.toggle()
        }
    }
    BarText { // Volume, click toggles the volume menu
        id: volumeTxt
        text: VolumelvlProc.barTxt

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: VolumeDropdownState.toggle()
        }
    }
    BarText {
        text: RamProc.barTxt
    } // RAM
    BarText {
        text: CpuProc.barTxt
    } // CPU
    Text { // Battery
        text: Battery.barTxt
        color: (Battery.level > 25) ? Theme.foreground : Theme.red
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
            bold: true
        }
    }
}
