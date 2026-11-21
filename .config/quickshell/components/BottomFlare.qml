import QtQuick
import QtQuick.Shapes
import "root:/"

Shape {
    id: root

    property real flare: Theme.curveFlare
    property color fill: Theme.background

    readonly property real f: flare
    readonly property real h: height
    readonly property real kx: flare * 0.5523   // handles of a quarter ellipse
    readonly property real ky: height * 0.5523
    readonly property real w: width

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.fill
        strokeColor: "transparent"

        // up out of the parent's left side, along the bottom edge, back up into its right side
        PathSvg {
            path: `M ${f} 0 C ${f} ${ky} ${kx} ${h} 0 ${h} L ${w} ${h} C ${w - kx} ${h} ${w - f} ${ky} ${w - f} 0 Z`
        }
    }
}
