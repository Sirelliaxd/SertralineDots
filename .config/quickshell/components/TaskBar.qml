import Quickshell
import Quickshell.Wayland
import QtQuick

import "root:/"
import "root:/bar"

// The notch. The bar's left and right ends are in components/Border.qml.
Variants {
  model: Quickshell.screens

  Scope {
    id: scope
    required property var modelData

    PanelWindow {
      screen: scope.modelData
      anchors { top: true }
      implicitWidth: centerContent.implicitWidth + 165
      implicitHeight: Theme.barHeight
      exclusiveZone: Theme.barHeight
      color: "transparent"
      WlrLayershell.namespace: "quickshell-notch"

      WaveShape {
        anchors.fill: parent
        mode: "center"
        flare: Theme.taskbarFlare
        fill: Theme.background
      }

      Center {
        id: centerContent
        anchors.centerIn: parent
      }
    }
  }
}
