// Credits:
// initially built based on @LinuxGuys lanucher
// https://www.youtube.com/watch?v=xE0uWhxC4uA
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

import "root:/"
import "root:/components"
import "root:/modules"

PanelWindow {
    id: root
    property var screen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ApplauncherState.launcherVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-app-launcher"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        bottom: -Theme.borderThickness
    }

    mask: Region {
        item: ApplauncherState.launcherVisible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    color: "transparent"

    // states
    property string searchQuery: ""
    property int selectedIndex: 0
    readonly property bool isSelected: searchQuery.trim() !== ""

    property var filteredApps: {
        var q = searchQuery.trim().toLowerCase();
        var vals = DesktopEntries.applications.values;

        if (q !== "") {
            return vals.filter(function (e) {
                if (e.name.toLowerCase().indexOf(q) !== -1)
                    return true;
                if (e.genericName && e.genericName.toLowerCase().indexOf(q) !== -1)
                    return true;
                for (var i = 0; i < e.keywords.length; i++)
                    if (e.keywords[i].toLowerCase().indexOf(q) !== -1)
                        return true;
                return false;
            }).sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
        }

        var recent = ApplauncherState.recentIds || [];
        return vals.slice().sort(function (a, b) {
            var ai = recent.indexOf(a.id);
            var bi = recent.indexOf(b.id);

            if (ai !== -1 && bi !== -1)
                return ai - bi;
            if (ai !== -1)
                return -1;
            if (bi !== -1)
                return 1;
            return a.name.localeCompare(b.name);
        });
    }

    onFilteredAppsChanged: selectedIndex = 0

    function launchEntry(entry) {
        ApplauncherState.recordLaunch(entry.id);
        entry.execute();
        ApplauncherState.hide();
    }

    function navigate(delta) {
        if (filteredApps.length === 0)
            return;

        selectedIndex = (selectedIndex + delta + filteredApps.length) % filteredApps.length;
        listView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    Connections {
        target: ApplauncherState
        function onLauncherVisibleChanged() {
            if (ApplauncherState.launcherVisible)
                root.onOpened();
        }
    }

    // The window is built when it opens
    Component.onCompleted: {
        if (ApplauncherState.launcherVisible)
            root.onOpened();
    }

    function onOpened() {
        searchInput.text = "";
        root.searchQuery = "";
        root.selectedIndex = 0;
        Qt.callLater(searchInput.forceActiveFocus);
    }

    // colors
    readonly property color accentFill: Theme.background
    readonly property color accentIcon: Theme.foreground
    readonly property color fgDim: Theme.inactive

    // geometry
    readonly property int maxVisible: Theme.appLauncherMaxVisible
    readonly property int itemH: Theme.appLauncherItemHeight
    readonly property int panelW: Theme.appLauncherPanelWidth
    readonly property int panelH: Theme.appLauncherPanelHeight + Math.min(filteredApps.length, maxVisible) * itemH

    // close on click outside window
    MouseArea {
        anchors.fill: parent
        enabled: ApplauncherState.launcherVisible
        onClicked: ApplauncherState.hide()
    }

    // -- Launcher main body --
    Item {
        id: panel
        width: root.panelW + 2 * Theme.appLauncherFlare
        // `shown` flips after creation so a window built on demand still animates open
        property bool shown: false
        Component.onCompleted: shown = true
        height: ApplauncherState.launcherVisible && panel.shown ? root.panelH : 0
        Behavior on height {
            NumberAnimation {
                duration: Theme.appLauncherHeightAnimDuration
                easing.type: Theme.appLauncherHeightAnimType
            }
        }

        clip: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Rectangle {
            id: body
            width: root.panelW
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                bottom: bottomCap.top
            }
            color: Theme.background
            topLeftRadius: Theme.appLauncherRadiusTop
            topRightRadius: Theme.appLauncherRadiusTop
        }

        BottomFlare {
            id: bottomCap
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: Theme.appLauncherFlareHeight
            flare: Theme.appLauncherFlare
            fill: Theme.background
        }

        // -- Content --
        Column {
            anchors {
                top: parent.top
                topMargin: Theme.appLauncherContentMargin
                left: body.left
                leftMargin: Theme.appLauncherContentMargin
                right: body.right
                rightMargin: Theme.appLauncherContentMargin
            }
            spacing: Theme.appLauncherContentSpacing

            // drag handle
            Rectangle {
                width: Theme.appLauncherDragWidth
                height: Theme.appLauncherDragHeight
                radius: Theme.appLauncherDragRadius
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.bg
            }

            // -- search box --
            Rectangle {
                width: parent.width
                height: Theme.appLauncherSearchBoxHeight
                radius: Theme.appLauncherSearchBoxRadius
                color: Theme.bg

                Rectangle {  // focus border
                    anchors.fill: parent
                    radius: Theme.appLauncherSearchBoxRadius
                    color: "transparent"
                    border.color: Theme.border
                    border.width: Theme.appLauncherSearchboxFocusBorderWidth
                    opacity: searchInput.activeFocus ? Theme.appLauncherSearchBoxFocusOpacity : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.appLauncherSearchBoxFocusAnimDuration
                        }
                    }
                }

                Item {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.appLauncherSearchBoxRowMargin
                        verticalCenter: parent.verticalCenter
                    }
                    width: parent.width - Theme.appLauncherInvContSubsFromWidth
                    height: parent.height

                    Text {
                        anchors.fill: parent
                        text: Theme.appLauncherSearchBoxText
                        color: Theme.foreground
                        opacity: Theme.appLauncherSearchBoxTextOpacity
                        font {
                            pixelSize: Theme.appLauncherSearchBoxTextSize
                            family: Theme.fontFamily
                        }
                        verticalAlignment: Text.AlignVCenter
                        visible: searchInput.text === ""
                    }

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        color: Theme.foreground
                        selectionColor: root.accentFill
                        font {
                            pixelSize: Theme.appLauncherSearchBoxTextSize
                            family: Theme.fontFamily
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true

                        onTextChanged: root.searchQuery = text
                    }

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Up) {
                            root.navigate(-1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            root.navigate(1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.filteredApps.length > 0)
                                root.launchEntry(root.filteredApps[root.selectedIndex]);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            ApplauncherState.hide();
                            event.accepted = true;
                        }
                    }
                }
            }

            Item {  // space between search box and app list
                width: 1
                height: Theme.applauncherSpaceBtwnSearchAndApps
            }

            ListView {
                id: listView
                width: parent.width
                height: Math.min(root.filteredApps.length, root.maxVisible) * root.itemH
                model: root.filteredApps
                clip: true
                interactive: false

                MouseArea {
                    anchors.fill: parent
                    onWheel: function (wheel) {
                        if (wheel.angleDelta.y < 0)
                            root.navigate(1);
                        else
                            root.navigate(-1);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredApps.length === 0
                    text: Theme.appLauncherNoAppsFound
                    color: Theme.foreground
                    opacity: Theme.appLauncherNoAppsFoundOpacity
                    font {
                        pixelSize: Theme.appLauncherSearchBoxTextSize
                        family: Theme.fontFamily
                    }
                }

                delegate: Item {
                    id: appRow
                    width: listView.width
                    height: root.itemH

                    readonly property bool sel: root.selectedIndex === index
                    readonly property bool isRecent: !root.isSelected && ApplauncherState.recentIds.indexOf(modelData.id) !== -1 && ApplauncherState.recentIds.indexOf(modelData.id) < 5
                    // an icon that does not resolve is drawn as a placeholder square, so treat
                    // it as missing and let the letter show instead
                    readonly property string iconSrc: modelData.icon !== "" && Quickshell.iconPath(modelData.icon, true) !== "" ? "image://icon/" + modelData.icon : ""

                    Rectangle {
                        anchors {
                            fill: parent
                            topMargin: Theme.appLauncherAppBgMargin
                            bottomMargin: Theme.appLauncherAppBgMargin
                        }
                        radius: Theme.appLaucncherAppBgRadius
                        color: appRow.sel ? root.accentFill : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.appLauncherAppBgAnimDuration
                            }
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: Theme.appLauncherIconBubbleMargin
                                rightMargin: Theme.appLauncherIconBubbleMargin
                            }
                            spacing: Theme.appLauncherIconBubbleSpacing

                            Rectangle {
                                width: Theme.appLauncherIconBubbleSize
                                height: Theme.appLauncherIconBubbleSize
                                radius: Theme.appLauncherIconBubbleRadius
                                anchors.verticalCenter: parent.verticalCenter
                                color: appRow.sel ? root.accentIcon : Theme.foregroundTransparent
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.appLauncherIconBubbleAnimDuration
                                    }
                                }

                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: Theme.appLauncherIconImgSize
                                    height: Theme.appLauncherIconImgSize
                                    source: appRow.iconSrc
                                    smooth: true
                                    mipmap: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: appIcon.status !== Image.Ready
                                    text: modelData.name.charAt(0).toUpperCase()
                                    font {
                                        pixelSize: Theme.appLauncherIconImgFallbackTxtSize
                                        family: Theme.fontFamily
                                        weight: Font.Bold
                                    }
                                    color: appRow.sel ? Theme.appLauncherIconFallbackColorActive : Theme.appLauncherIconImgFallbackColorInactive
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.appLauncherIconFallbackAnimDuration
                                        }
                                    }
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.appLauncherAppNamesSpacing

                                Text {
                                    text: modelData.name
                                    font {
                                        pixelSize: Theme.appLauncherAppNamesFontSize
                                        family: Theme.fontFamily
                                        weight: appRow.sel ? Font.Medium : Font.Normal
                                    }
                                    color: appRow.sel ? Theme.appLauncherAppNamesColorActive : root.fgDim
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.appLauncherAppNamesAnimDuration
                                        }
                                    }
                                }

                                Row {
                                    spacing: Theme.appLauncherRecentlyUsedSpacing
                                    visible: appRow.isRecent || modelData.genericName !== ""

                                    Rectangle {
                                        visible: appRow.isRecent
                                        width: recentLabel.width + Theme.appLauncherRecentAppsWidthAddition
                                        height: Theme.appLauncherRecentAppsHeight
                                        radius: Theme.appLauncherRecentAppsRadius
                                        color: Theme.appLauncherRecentlAppsColor
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: recentLabel
                                            anchors.centerIn: parent
                                            text: Theme.appLauncherRecentAppsText
                                            font {
                                                pixelSize: Theme.appLauncherRecentAppsTxtSize
                                                family: Theme.fontFamily
                                            }
                                            color: Theme.appLauncherRecentAppsTxtColor
                                        }
                                    }

                                    Text {
                                        visible: modelData.genericName !== ""
                                        text: modelData.genericName
                                        font {
                                            pixelSize: Theme.appLauncherRecentsGenericTxtSize
                                            family: Theme.fontFamily
                                        }
                                        color: Theme.appLauncherRecentsGenericTxtColor
                                        opacity: Theme.appLauncherRecentsGenericTxtOpacity
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: root.launchEntry(modelData)
                            onWheel: function (wheel) {
                                if (wheel.angleDelta.y < 0)
                                    root.navigate(1);
                                else
                                    root.navigate(-1);
                            }
                        }
                    }
                }
            }

            Item {  // bottom padding
                width: Theme.appLauncherBottomItemWidth
                height: Theme.appLauncherBottomitemHeight
            }
        }
    }
}
