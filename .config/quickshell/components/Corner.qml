import QtQuick
import QtQuick.Shapes

import "root:/"

Shape {
    id: root

    property int radius: 14
    property color color: Theme.bgTs
    // Canonical corner is top-left. Mirror it for the others.
    property bool flipX: false
    property bool flipY: false

    implicitWidth: radius
    implicitHeight: radius

    preferredRendererType: Shape.CurveRenderer

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.flipX ? -1 : 1
        yScale: root.flipY ? -1 : 1
    }

    ShapePath {
        fillColor: root.color
        strokeColor: "transparent"

        // top-left corner, concave: square minus a quarter circle centred at (r, r)
        startX: 0
        startY: 0

        PathLine {
            x: root.radius
            y: 0
        }

        PathArc {
            x: 0
            y: root.radius
            radiusX: root.radius
            radiusY: root.radius
            direction: PathArc.Counterclockwise
        }

        PathLine {
            x: 0
            y: 0
        }
    }
}
