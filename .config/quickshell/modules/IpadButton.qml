import QtQuick
import "root:/"
import "root:/bar"
import "root:/modules"

Item {
    implicitWidth: 14
    implicitHeight: 18

    Text {
        anchors.centerIn: parent
        text: OdSender.icon
        color: Theme.foreground
        font {
          family: Theme.fontFamily
          pixelSize: Theme.fontSize
          bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: OdSender.toggle()
    }
}
