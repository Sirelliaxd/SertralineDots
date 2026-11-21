import QtQuick
import "root:/"

Item {
    id: root

    property real value: 0

    signal moved(real level)

    implicitHeight: Theme.volumeDropdownSliderKnobSize

    function setFrom(x) {
        root.moved(Math.max(0, Math.min(1, x / width)));
    }

    Rectangle {  // track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Theme.volumeDropdownSliderHeight
        radius: Theme.volumeDropdownSliderHeight / 2
        color: Theme.volumeDropdownTrackColor
    }

    Rectangle {  // fill; a node can sit above 1.0, the bar just stays full
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * Math.min(root.value, 1)
        height: Theme.volumeDropdownSliderHeight
        radius: Theme.volumeDropdownSliderHeight / 2
        color: Theme.volumeDropdownFillColor
    }

    Rectangle {  // knob
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(parent.width - width, parent.width * Math.min(root.value, 1) - width / 2))
        width: Theme.volumeDropdownSliderKnobSize
        height: Theme.volumeDropdownSliderKnobSize
        radius: width / 2
        color: Theme.volumeDropdownFillColor
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // A Flickable ancestor must not steal the drag: dragging the knob would scroll the panel
        preventStealing: true
        onPressed: function (mouse) {
            root.setFrom(mouse.x);
        }
        onPositionChanged: function (mouse) {
            if (pressed)
                root.setFrom(mouse.x);
        }
    }
}
