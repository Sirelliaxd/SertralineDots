import Quickshell
import QtQuick
import "root:/"


Item { // Center
  id: root

  anchors.centerIn: parent

  // Clock data
  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  
  Text {
    text: "   " + Qt.formatDateTime(clock.date, "ss")
    color: Theme.foreground
    anchors.right: time.left
    anchors.rightMargin: 5
    anchors.baseline: time.baseline
    font { family: Theme.fontFamily; pixelSize: (Theme.fontSize * 0.6); bold: false }
  }
  BarText {
    id: time
    text: Qt.formatDateTime(clock.date, "hh:mm")
    color: Theme.foreground
    anchors.centerIn: parent
  }
  Text {
    text: Qt.formatDateTime(clock.date, "dd-MM")
    color: Theme.foreground
    anchors.left: time.right
    anchors.leftMargin: 5
    anchors.baseline: time.baseline
    font { family: Theme.fontFamily; pixelSize: (Theme.fontSize * 0.6); bold: false }
  }
}
