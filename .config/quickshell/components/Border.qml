// Credits:
// initially built based on @LinuxGuys lanucher
// https://www.youtube.com/watch?v=11RaUUPSWlM
import Quickshell
import Quickshell.Wayland
import QtQuick

import "root:/"
import "root:/bar"
import "root:/modules"

Scope {
    id: root
    property int thickness: Theme.borderThickness
    property color borderColor: Theme.background

    Variants {
        model: Quickshell.screens

        Item {
            id: screenRoot
            required property var modelData

            PanelWindow { // bottom
                screen: screenRoot.modelData
                anchors {
                    bottom: true
                    left: true
                    right: true
                }
                implicitHeight: root.thickness
                exclusiveZone: root.thickness
                color: "transparent"
                mask: Region {}
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-border"
            }

            PanelWindow { // left
                screen: screenRoot.modelData
                anchors {
                    top: true
                    bottom: true
                    left: true
                }
                margins {
                    top: Theme.barHeight
                }
                implicitWidth: root.thickness
                exclusiveZone: root.thickness
                color: "transparent"
                mask: Region {}
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-border"
            }

            PanelWindow { // right
                screen: screenRoot.modelData
                anchors {
                    top: true
                    bottom: true
                    right: true
                }
                margins {
                    top: Theme.barHeight
                }
                implicitWidth: root.thickness
                exclusiveZone: root.thickness
                color: "transparent"
                mask: Region {}
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-border"
            }

            // Frame, corners and both bar ends in one surface, so Hyprland blurs the
            // whole frame in one pass instead of once per surface.
            PanelWindow {
                screen: screenRoot.modelData

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.namespace: "quickshell-border"

                // Only the bar strip takes input; frame and corners stay click-through.
                mask: Region {
                    item: barInput
                }
                Item {
                    id: barInput
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: Theme.barHeight
                }

                Rectangle { // bottom
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: root.thickness
                    color: root.borderColor
                }

                Rectangle { // left
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        topMargin: Theme.barHeight
                    }
                    width: root.thickness
                    color: root.borderColor
                }

                Rectangle { // right
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        topMargin: Theme.barHeight
                    }
                    width: root.thickness
                    color: root.borderColor
                }

                Corners {}

                Item { // left bar end
                    id: leftEnd
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    height: Theme.barHeight
                    width: leftContent.implicitWidth + Theme.pad + Theme.taskbarFlare

                    WaveShape {
                        anchors.fill: parent
                        mode: "left"
                        flare: Theme.taskbarFlare
                        fill: root.borderColor
                    }

                    Left {
                        id: leftContent
                    }
                }

                Item { // right bar end
                    id: rightEnd
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                    height: Theme.barHeight
                    width: rightContent.implicitWidth + Theme.pad + Theme.taskbarFlare

                    WaveShape {
                        anchors.fill: parent
                        mode: "right"
                        flare: Theme.taskbarFlare
                        fill: root.borderColor
                    }

                    Right {
                        id: rightContent
                        screen: screenRoot.modelData  // fixed position under tab icon
                    }
                }
            }
        }
    }
}
