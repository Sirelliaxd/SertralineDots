import QtQuick
import QtQuick.Shapes
import "root:/"

Shape {
  id: root

  property string mode: "center"        // "left" | "right" | "center"
  property real flare: Theme.curveFlare               // horizontal length of the wave
  property color fill: Theme.background

  readonly property real k: flare * 0.55 // handle length, higher = softer S
  readonly property real w: width
  readonly property real h: height
  readonly property real f: flare

  readonly property string d: {
    if (mode === "left")
      return `M 0 0 L 0 ${h} L ${w - f} ${h} C ${w - f + k} ${h} ${w - k} 0 ${w} 0 Z`
    if (mode === "right")
      return `M ${w} 0 L ${w} ${h} L ${f} ${h} C ${f - k} ${h} ${k} 0 0 0 Z`
    // center: wave on both sides
    return `M 0 0 C ${k} 0 ${f - k} ${h} ${f} ${h} L ${w - f} ${h} C ${w - f + k} ${h} ${w - k} 0 ${w} 0 Z`
  }

  preferredRendererType: Shape.CurveRenderer   // smooth edges, Qt 6.6+

  ShapePath {
    fillColor: root.fill
    strokeColor: "transparent"
    PathSvg { path: root.d }
  }
}
