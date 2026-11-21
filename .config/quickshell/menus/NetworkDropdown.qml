import Quickshell
import Quickshell.Wayland
import QtQuick

import "root:/"
import "root:/modules"
import "root:/components"

// Network menu, opened from the network readout in the bar's right end: the connected
// network, addresses, MACs, the wifi radio, scanning, saved connections, the connection
// editor, the VPN, MAC randomisation, monitor mode, listening ports and a load graph.
// The data comes from NetInfo, the graph from NetLoad
PanelWindow {
  id: root

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: NetworkMenuState.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  WlrLayershell.namespace: "quickshell-network-dropdown"

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"

  // Only take input while open, and only the panel is clickable; a click anywhere
  // else closes the menu.
  mask: Region {
    item: NetworkMenuState.visible ? maskCover : null
  }
  Item {
    id: maskCover
    anchors.fill: parent
  }

  readonly property int panelW: Theme.networkDropdownPanelWidth

  property real anchorX: NetworkMenuState.anchorX

  // One list open at a time
  property bool scanOpen: false
  property bool connOpen: false
  property bool portsOpen: false
  property bool ifaceOpen: false
  property string ifaceDetail: ""  // device whose stats are open

  property string selectedKey: "wifi"

  // Covers the public address and the MACs until the row is switched on
  property bool revealDetails: false

  readonly property string statusIcon: NetInfo.wiredName !== "" ? Theme.networkDropdownPortsIcon
    : (NetInfo.wifiOn ? Theme.networkDropdownIcon : Theme.networkDropdownIconOff)
  readonly property string statusValue: NetInfo.connected
    ? NetInfo.connectedName + (NetInfo.activeWifi ? "  " + NetInfo.wifiSignal + "%" : "")
    : Theme.networkDropdownOffText

  function shortType(type) {
    if (type === "802-11-wireless")
      return "wifi";
    if (type === "802-3-ethernet")
      return "eth";
    if (type === "wireguard")
      return "wg";
    return type;
  }

  // A long network name would push the centred line out of the panel, so it is cut to
  // Theme.networkDropdownSsidMax with an ellipsis.
  function clip(text, max) {
    return text.length > max ? text.substring(0, max - 1) + "\u2026" : text;
  }

  function cover(value) {
    return root.revealDetails ? value : value.replace(/[0-9a-zA-Z]/g, Theme.networkDropdownMaskChar);
  }

  function ifaceStats(iface) {
    var lines = iface.stats.slice();
    if (iface.mac !== "")
      lines.push("link/" + iface.linkKind + "  " + root.cover(iface.mac));
    return lines;
  }

  // Keyboard selection.
  readonly property var navRows: {
    var rows = ["reveal", "wifi", "scan"];
    var i;
    if (scanOpen) {
      rows.push("scan-rescan");
      for (i = 0; i < NetInfo.wifiNetworks.length; i++)
        rows.push("net-" + NetInfo.wifiNetworks[i].ssid);
    }
    rows.push("connections");
    if (connOpen)
      for (i = 0; i < NetInfo.connections.length; i++)
        rows.push("conn-" + NetInfo.connections[i].name);
    rows.push("interfaces");
    if (ifaceOpen)
      for (i = 0; i < NetInfo.interfaces.length; i++)
        rows.push("iface-" + NetInfo.interfaces[i].name);
    rows.push("edit");
    rows.push("vpn");
    rows.push("randommac");
    rows.push("monitor");
    rows.push("ports");
    if (portsOpen)
      for (i = 0; i < NetInfo.ports.length; i++)
        if (NetInfo.ports[i].kind === "socket")
          rows.push("port-" + i);
    for (i = 0; i < NetInfo.daemons.length; i++)
      rows.push("daemon-" + NetInfo.daemons[i].name);
    return rows;
  }

  function move(delta) {
    var idx = navRows.indexOf(selectedKey);
    if (idx < 0)
      idx = delta > 0 ? -1 : 0;
    selectedKey = navRows[(idx + delta + navRows.length) % navRows.length];
    Qt.callLater(root.ensureVisible);
  }

  function activate(key) {
    if (key === "reveal") {
      revealDetails = !revealDetails;
    } else if (key === "wifi") {
      NetInfo.setWifiEnabled(!NetInfo.wifiOn);
    } else if (key === "scan") {
      scanOpen = !scanOpen;
      if (scanOpen)
        NetInfo.refreshWifi();
    } else if (key === "scan-rescan") {
      NetInfo.rescan();
    } else if (key.indexOf("net-") === 0) {
      NetInfo.connectWifi(key.substring(4));
      scanOpen = false;
      selectedKey = "scan";
    } else if (key === "connections") {
      connOpen = !connOpen;
    } else if (key.indexOf("conn-") === 0) {
      NetInfo.activate(key.substring(5));
      connOpen = false;
      selectedKey = "connections";
    } else if (key === "interfaces") {
      ifaceOpen = !ifaceOpen;
    } else if (key.indexOf("iface-") === 0) {
      var device = key.substring(6);
      ifaceDetail = ifaceDetail === device ? "" : device;
    } else if (key === "edit") {
      NetInfo.openEditor();
    } else if (key === "vpn") {
      NetInfo.openMullvad();
    } else if (key === "randommac") {
      NetInfo.randomMac(!NetInfo.macRandom);
    } else if (key === "monitor") {
      NetInfo.monitorMode(!NetInfo.monitorOn);
    } else if (key === "ports") {
      portsOpen = !portsOpen;
    }
  }

  // Keep the selected row inside the scroll area
  function ensureVisible() {
    for (var i = 0; i < content.children.length; i++) {
      var row = content.children[i];
      if (row.rowKey === undefined || row.rowKey !== selectedKey)
        continue;
      if (row.y < flick.contentY)
        flick.contentY = row.y;
      else if (row.y + row.height > flick.contentY + flick.height)
        flick.contentY = Math.min(row.y + row.height - flick.height,
                                  Math.max(0, content.implicitHeight - flick.height));
      return;
    }
  }

  Connections {
    target: NetworkMenuState

    function onVisibleChanged() {
      if (NetworkMenuState.visible)
        root.onOpened();
    }
  }

  // The window is built when it opens
  Component.onCompleted: {
    if (NetworkMenuState.visible)
      root.onOpened();
  }

  // The menu only runs while this window exists
  Component.onDestruction: NetLoad.stop()

  function onOpened() {
    scanOpen = false;
    connOpen = false;
    portsOpen = false;
    ifaceOpen = false;
    ifaceDetail = "";
    revealDetails = false;
    selectedKey = "reveal";
    anchorX = NetworkMenuState.anchorX;
    NetInfo.refresh();
    NetLoad.start(NetInfo.activeInterface);
    Qt.callLater(panel.forceActiveFocus);
  }

  MouseArea {
    anchors.fill: parent
    enabled: NetworkMenuState.visible
    onClicked: NetworkMenuState.hide()
  }

  // One cell of the info group: bubble, then a small label above its value
  component StatCell: Item {
    id: statCell

    property string icon: ""
    property string label: ""
    property string value: ""

    width: infoGrid.cellW
    height: Theme.networkDropdownStatHeight

    Rectangle {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
      }
      width: Theme.networkDropdownIconBubbleSize
      height: Theme.networkDropdownIconBubbleSize
      radius: Theme.networkDropdownIconBubbleRadius
      color: Theme.foregroundTransparent

      Text {
        anchors.centerIn: parent
        text: statCell.icon
        color: Theme.foreground
        font {
          family: Theme.fontFamily
          pixelSize: Theme.networkDropdownIconSize
        }
      }
    }

    Column {
      anchors {
        left: parent.left
        leftMargin: Theme.networkDropdownIconBubbleSize + 10
        right: parent.right
        verticalCenter: parent.verticalCenter
      }
      spacing: 3

      Text {
        width: parent.width
        text: statCell.label
        elide: Text.ElideRight
        color: Theme.networkDropdownDimColor
        font {
          family: Theme.fontFamily
          pixelSize: Theme.networkDropdownLabelSize
        }
      }

      Text {
        width: parent.width
        text: statCell.value
        elide: Text.ElideRight
        color: Theme.foreground
        font {
          family: Theme.fontFamily
          pixelSize: Theme.networkDropdownFontSize
        }
      }
    }
  }

  // A row that does something when clicked: bubble, label, value
  component ActionRow: Item {
    id: actionRow

    property string rowKey: ""
    property string icon: ""
    property string label: ""
    property string value: ""
    property bool highlight: false
    property bool selected: false
    property color iconColor: Theme.foreground

    signal clicked()

    width: parent.width
    height: Theme.networkDropdownRowHeight

    Rectangle {
      anchors.fill: parent
      radius: Theme.networkDropdownRowRadius
      color: actionHover.containsMouse || actionRow.selected ? Theme.background : "transparent"
      Behavior on color {
        ColorAnimation {
          duration: 100
        }
      }
    }

    Rectangle {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
      }
      width: Theme.networkDropdownIconBubbleSize
      height: Theme.networkDropdownIconBubbleSize
      radius: Theme.networkDropdownIconBubbleRadius
      color: actionRow.highlight ? Theme.foreground : Theme.foregroundTransparent
      Behavior on color {
        ColorAnimation {
          duration: 100
        }
      }

      Text {
        anchors.centerIn: parent
        text: actionRow.icon
        color: actionRow.highlight ? Theme.background : actionRow.iconColor
        font {
          family: Theme.fontFamily
          pixelSize: Theme.networkDropdownIconSize
        }
      }
    }

    Text {
      anchors {
        left: parent.left
        leftMargin: Theme.networkDropdownIconBubbleSize + 10
        verticalCenter: parent.verticalCenter
      }
      width: Theme.networkDropdownLabelWidth
      text: actionRow.label
      elide: Text.ElideRight
      color: Theme.foreground
      font {
        family: Theme.fontFamily
        pixelSize: Theme.networkDropdownFontSize
      }
    }

    Text {
      anchors {
        left: parent.left
        leftMargin: Theme.networkDropdownIconBubbleSize + 10 + Theme.networkDropdownLabelWidth + 10
        right: parent.right
        rightMargin: 8
        verticalCenter: parent.verticalCenter
      }
      text: actionRow.value
      elide: Text.ElideRight
      color: Theme.networkDropdownDimColor
      font {
        family: Theme.fontFamily
        pixelSize: Theme.networkDropdownFontSize
      }
    }

    MouseArea {
      id: actionHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.selectedKey = actionRow.rowKey
      onClicked: {
        root.selectedKey = actionRow.rowKey;
        actionRow.clicked();
      }
    }
  }

  // An ActionRow that flips a state when clicked
  component ToggleRow: ActionRow {
    signal toggled()

    onClicked: toggled()
  }

  // An ActionRow with a chevron: it opens a list under itself
  component ListRow: Item {
    id: listRow

    property string rowKey: ""
    property string icon: ""
    property string label: ""
    property string value: ""
    property bool expanded: false
    property bool selected: false
    // the interface rows use these to make the device name stand out from the rest of the row
    property bool labelBold: false
    property int labelSize: Theme.networkDropdownFontSize
    property bool highlight: false

    signal clicked()

    width: parent.width
    height: Theme.networkDropdownRowHeight

    Rectangle {
      anchors.fill: parent
      radius: Theme.networkDropdownRowRadius
      color: listHover.containsMouse || listRow.expanded || listRow.selected || listRow.highlight ? Theme.background : "transparent"
      Behavior on color {
        ColorAnimation {
          duration: 100
        }
      }
    }

    Rectangle {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
      }
      width: Theme.networkDropdownIconBubbleSize
      height: Theme.networkDropdownIconBubbleSize
      radius: Theme.networkDropdownIconBubbleRadius
      color: listHover.containsMouse || listRow.expanded || listRow.selected || listRow.highlight ? Theme.foreground : Theme.foregroundTransparent
      Behavior on color {
        ColorAnimation {
          duration: 100
        }
      }

      Text {
        anchors.centerIn: parent
        text: listRow.icon
        color: listHover.containsMouse || listRow.expanded || listRow.selected || listRow.highlight ? Theme.background : Theme.foreground
        font {
          family: Theme.fontFamily
          pixelSize: Theme.networkDropdownIconSize
        }
      }
    }

    Text {
      anchors {
        left: parent.left
        leftMargin: Theme.networkDropdownIconBubbleSize + 10
        verticalCenter: parent.verticalCenter
      }
      width: Theme.networkDropdownLabelWidth
      text: listRow.label
      elide: Text.ElideRight
      color: Theme.foreground
      font {
        family: Theme.fontFamily
        pixelSize: listRow.labelSize
        bold: listRow.labelBold
      }
    }

    Text {
      anchors {
        left: parent.left
        leftMargin: Theme.networkDropdownIconBubbleSize + 10 + Theme.networkDropdownLabelWidth + 10
        right: listChevron.left
        rightMargin: 10
        verticalCenter: parent.verticalCenter
      }
      text: listRow.value
      elide: Text.ElideRight
      color: Theme.networkDropdownDimColor
      font {
        family: Theme.fontFamily
        pixelSize: Theme.networkDropdownFontSize
      }
    }

    Text {
      id: listChevron
      anchors {
        right: parent.right
        rightMargin: 8
        verticalCenter: parent.verticalCenter
      }
      text: listRow.expanded ? Theme.networkDropdownChevronOpen : Theme.networkDropdownChevronClosed
      color: Theme.networkDropdownDimColor
      font {
        family: Theme.fontFamily
        pixelSize: Theme.networkDropdownIconSize
      }
    }

    MouseArea {
      id: listHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.selectedKey = listRow.rowKey
      onClicked: {
        root.selectedKey = listRow.rowKey;
        listRow.clicked();
      }
    }
  }

  // One entry of an opened list
  component EntryRow: Item {
    id: entryRow

    property string rowKey: ""
    property string text: ""
    property string value: ""
    property bool active: false
    property bool selected: false

    signal clicked()

    // children of a dropdown
    x: Theme.networkDropdownChildIndent
    width: parent.width - 2 * Theme.networkDropdownChildIndent
    height: Theme.networkDropdownEntryRowHeight

    Rectangle {
      anchors.fill: parent
      radius: Theme.networkDropdownRowRadius
      color: entryHover.containsMouse || entryRow.selected ? Theme.background : "transparent"
      Behavior on color {
        ColorAnimation {
          duration: 100
        }
      }
    }

    Text {
      anchors {
        left: parent.left
        leftMargin: Theme.networkDropdownEntryIndent - Theme.networkDropdownChildIndent
        right: entryValue.left
        rightMargin: 10
        verticalCenter: parent.verticalCenter
      }
      text: entryRow.text
      elide: Text.ElideRight
      color: entryRow.active ? Theme.foreground : Theme.networkDropdownDimColor
      font {
        family: Theme.fontFamily
        pixelSize: Theme.networkDropdownFontSize
        bold: entryRow.active
      }
    }

    Text {
      id: entryValue
      anchors {
        right: parent.right
        rightMargin: 8
        verticalCenter: parent.verticalCenter
      }
      text: entryRow.value
      color: Theme.networkDropdownDimColor
      font {
        family: Theme.fontFamily
        pixelSize: Theme.networkDropdownFontSize
      }
    }

    MouseArea {
      id: entryHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.selectedKey = entryRow.rowKey
      onClicked: {
        root.selectedKey = entryRow.rowKey;
        entryRow.clicked();
      }
    }
  }

  // A dim line for an empty list
  component EmptyRow: Item {
    id: emptyRow

    property string text: ""

    width: parent.width
    height: Theme.networkDropdownEntryRowHeight

    Text {
      anchors {
        left: parent.left
        leftMargin: Theme.networkDropdownEntryIndent
        verticalCenter: parent.verticalCenter
      }
      text: emptyRow.text
      color: Theme.networkDropdownDimColor
      font {
        family: Theme.fontFamily
        pixelSize: Theme.networkDropdownFontSize
      }
    }
  }

  Item {
    id: panel
    anchors {
      top: parent.top
      left: parent.left
      topMargin: Theme.networkDropdownMargin
      leftMargin: Math.max(Theme.networkDropdownMargin,
                           Math.min(root.anchorX - panel.width / 2,
                                    root.width - panel.width - Theme.networkDropdownMargin))
    }

    property bool shown: false
    Component.onCompleted: shown = true
    width: NetworkMenuState.visible && panel.shown ? root.panelW : 0
    height: NetworkMenuState.visible && panel.shown ? flick.height + 2 * Theme.networkDropdownContentMargin : 0
    clip: true
    focus: true

    Behavior on width {
      NumberAnimation {
        duration: Theme.networkDropdownAnimDuration
        easing.type: Theme.networkDropdownAnimType
      }
    }

    Behavior on height {
      NumberAnimation {
        duration: Theme.networkDropdownAnimDuration
        easing.type: Theme.networkDropdownAnimType
      }
    }

    Keys.onPressed: function (event) {
      if (event.key === Qt.Key_Escape) {
        NetworkMenuState.hide();
        event.accepted = true;
      } else if (event.key === Qt.Key_Up) {
        root.move(-1);
        event.accepted = true;
      } else if (event.key === Qt.Key_Down) {
        root.move(1);
        event.accepted = true;
      } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
        root.activate(root.selectedKey);
        event.accepted = true;
      }
    }

    Rectangle {
      anchors.fill: parent
      radius: Theme.networkDropdownRadius
      color: Theme.background
    }

    Flickable {
      id: flick
      x: Theme.networkDropdownContentMargin
      y: Theme.networkDropdownContentMargin
      width: root.panelW - 2 * Theme.networkDropdownContentMargin
      height: Math.min(content.implicitHeight, Theme.networkDropdownMaxContentHeight)
      contentWidth: width
      contentHeight: content.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Column {
        id: content
        width: flick.width
        spacing: 0

        Item {
          width: parent.width
          height: Theme.networkDropdownNicHeight

          Text {
            anchors.centerIn: parent
            text: (NetInfo.activeInterface !== "" ? NetInfo.activeInterface : Theme.networkDropdownEmptyText)
              + (NetInfo.ssid !== "" ? "  " + root.clip(NetInfo.ssid, Theme.networkDropdownSsidMax) : "")
            color: Theme.foreground
            font {
              family: Theme.fontFamily
              pixelSize: Theme.networkDropdownFontSize
            }
          }
        }

        Item {
          width: parent.width
          height: infoGrid.height + 2 * Theme.networkDropdownGroupPadding

          Rectangle {
            anchors.fill: parent
            radius: Theme.networkDropdownRowRadius
            color: Theme.background
          }

          Grid {
            id: infoGrid
            anchors {
              left: parent.left
              right: parent.right
              top: parent.top
              margins: Theme.networkDropdownGroupPadding
            }
            columns: 2
            columnSpacing: Theme.networkDropdownStatSpacing
            rowSpacing: Theme.networkDropdownStatSpacing
            readonly property real cellW: (width - columnSpacing) / 2

            StatCell {
              icon: root.statusIcon
              label: Theme.networkDropdownText
              value: root.statusValue
            }

            StatCell {
              icon: Theme.networkDropdownLocalIcon
              label: Theme.networkDropdownLocalText
              value: NetInfo.localAddress !== "" ? NetInfo.localAddress : Theme.networkDropdownEmptyText
            }

            StatCell {
              icon: Theme.networkDropdownPublicIcon
              label: Theme.networkDropdownPublicText
              value: root.cover(NetInfo.publicIp !== "" ? NetInfo.publicIp : Theme.networkDropdownEmptyText)
            }

            Repeater {
              model: NetInfo.links

              delegate: StatCell {
                icon: Theme.networkDropdownMacIcon
                label: modelData.device + (modelData.device !== NetInfo.activeInterface && NetInfo.addressOf(modelData.device) !== "" ? "  " + NetInfo.addressOf(modelData.device) : "")
                value: root.cover(modelData.mac)
              }
            }
          }
        }

        // Load row plus the graph under it
        Item {
          id: loadRow
          width: parent.width
          height: Theme.networkDropdownRowHeight + Theme.networkDropdownGraphHeight

          Rectangle {
            anchors {
              left: parent.left
              top: parent.top
              topMargin: (Theme.networkDropdownRowHeight - Theme.networkDropdownIconBubbleSize) / 2
            }
            width: Theme.networkDropdownIconBubbleSize
            height: Theme.networkDropdownIconBubbleSize
            radius: Theme.networkDropdownIconBubbleRadius
            color: Theme.foregroundTransparent

            Text {
              anchors.centerIn: parent
              text: Theme.networkDropdownLoadIcon
              color: Theme.foreground
              font {
                family: Theme.fontFamily
                pixelSize: Theme.networkDropdownIconSize
              }
            }
          }

          Text {
            anchors {
              left: parent.left
              leftMargin: Theme.networkDropdownIconBubbleSize + 10
              verticalCenter: parent.top
              verticalCenterOffset: Theme.networkDropdownRowHeight / 2
            }
            width: Theme.networkDropdownLabelWidth
            text: Theme.networkDropdownLoadText
            color: Theme.foreground
            font {
              family: Theme.fontFamily
              pixelSize: Theme.networkDropdownFontSize
            }
          }

          Text {
            anchors {
              left: parent.left
              leftMargin: Theme.networkDropdownIconBubbleSize + 10 + Theme.networkDropdownLabelWidth + 10
              right: parent.right
              rightMargin: 8
              verticalCenter: parent.top
              verticalCenterOffset: Theme.networkDropdownRowHeight / 2
            }
            text: "\u2193 " + NetLoad.formatRate(NetLoad.rxRate) + "   \u2191 " + NetLoad.formatRate(NetLoad.txRate)
            elide: Text.ElideRight
            color: Theme.networkDropdownDimColor
            font {
              family: Theme.fontFamily
              pixelSize: Theme.networkDropdownFontSize
            }
          }

          NetGraph {
            anchors {
              left: parent.left
              right: parent.right
              top: parent.top
              topMargin: Theme.networkDropdownRowHeight
            }
            height: Theme.networkDropdownGraphHeight
            samples: NetLoad.history
          }
        }

        // Divider between info and settings sections
        Item {
          width: parent.width
          height: Theme.networkDropdownSeparatorMargin * 2 + 1

          Rectangle {
            anchors {
              left: parent.left
              right: parent.right
              verticalCenter: parent.verticalCenter
            }
            height: 1
            color: Theme.networkDropdownSeparatorColor
          }
        }

        ToggleRow {
          rowKey: "reveal"
          icon: Theme.networkDropdownRevealIcon
          label: Theme.networkDropdownRevealText
          value: root.revealDetails ? Theme.networkDropdownOnText : Theme.networkDropdownOffText
          highlight: root.revealDetails
          selected: root.selectedKey === "reveal"
          onToggled: root.revealDetails = !root.revealDetails
        }

        ToggleRow {
          rowKey: "wifi"
          icon: NetInfo.wifiOn ? Theme.networkDropdownIcon : Theme.networkDropdownIconOff
          label: Theme.networkDropdownWifiText
          value: NetInfo.wifiOn ? Theme.networkDropdownOnText : Theme.networkDropdownOffText
          highlight: !NetInfo.wifiOn
          selected: root.selectedKey === "wifi"
          onToggled: NetInfo.setWifiEnabled(!NetInfo.wifiOn)
        }

        ListRow {
          rowKey: "scan"
          icon: Theme.networkDropdownNetworksIcon
          label: Theme.networkDropdownNetworksText
          value: NetInfo.wifiNetworks.length + ""
          expanded: root.scanOpen
          selected: root.selectedKey === "scan"
          onClicked: {
            root.scanOpen = !root.scanOpen;
            if (root.scanOpen)
              NetInfo.refreshWifi();
          }
        }

        EntryRow {
          visible: root.scanOpen
          rowKey: "scan-rescan"
          text: Theme.networkDropdownRescanText
          selected: root.selectedKey === "scan-rescan"
          onClicked: NetInfo.rescan()
        }

        Repeater {
          model: root.scanOpen ? NetInfo.wifiNetworks : []

          delegate: EntryRow {
            rowKey: "net-" + modelData.ssid
            text: modelData.ssid
            value: modelData.signal + "%" + (modelData.secured ? "  " + Theme.networkDropdownLockIcon : "")
            active: modelData.active
            selected: root.selectedKey === rowKey
            onClicked: {
              NetInfo.connectWifi(modelData.ssid);
              root.scanOpen = false;
              root.selectedKey = "scan";
            }
          }
        }

        EmptyRow {
          visible: root.scanOpen && NetInfo.wifiNetworks.length === 0
          text: Theme.networkDropdownNoNetworksText
        }

        ListRow {
          rowKey: "connections"
          icon: Theme.networkDropdownConnectionsIcon
          label: Theme.networkDropdownConnectionsText
          value: NetInfo.connections.length + ""
          expanded: root.connOpen
          selected: root.selectedKey === "connections"
          onClicked: root.connOpen = !root.connOpen
        }

        Repeater {
          model: root.connOpen ? NetInfo.connections : []

          delegate: EntryRow {
            rowKey: "conn-" + modelData.name
            text: modelData.name
            value: modelData.active ? Theme.networkDropdownOnText : root.shortType(modelData.type)
            active: modelData.active
            selected: root.selectedKey === rowKey
            onClicked: {
              NetInfo.activate(modelData.name);
              root.connOpen = false;
              root.selectedKey = "connections";
            }
          }
        }

        EmptyRow {
          visible: root.connOpen && NetInfo.connections.length === 0
          text: Theme.networkDropdownEmptyText
        }

        ListRow {
          rowKey: "interfaces"
          icon: Theme.networkDropdownInterfacesIcon
          label: Theme.networkDropdownInterfacesText
          value: NetInfo.interfaces.length + ""
          expanded: root.ifaceOpen
          selected: root.selectedKey === "interfaces"
          onClicked: root.ifaceOpen = !root.ifaceOpen
        }

        Repeater {
          model: root.ifaceOpen ? NetInfo.interfaces : []

          // Row and stats together
          delegate: Item {
            id: ifaceBlock

            property string rowKey: "iface-" + modelData.name

            x: Theme.networkDropdownChildIndent
            width: parent.width - 2 * Theme.networkDropdownChildIndent
            height: ifaceColumn.height

            Column {
              id: ifaceColumn
              width: parent.width

              ListRow {
                rowKey: ifaceBlock.rowKey
                icon: modelData.connected ? Theme.networkDropdownIfaceOnIcon : Theme.networkDropdownIfaceOffIcon
                label: modelData.name
                labelBold: true
                labelSize: Theme.networkDropdownIfaceNameSize
                value: (modelData.up ? Theme.networkDropdownUpText : Theme.networkDropdownDownText)
                  + (modelData.ip !== "" ? "  " + modelData.ip : "")
                expanded: root.ifaceDetail === modelData.name
                highlight: modelData.connected
                selected: root.selectedKey === ifaceBlock.rowKey
                onClicked: root.ifaceDetail = root.ifaceDetail === modelData.name ? "" : modelData.name
              }

              Column {
                width: parent.width
                visible: root.ifaceDetail === modelData.name
                spacing: 2
                topPadding: 2
                bottomPadding: 4

                Repeater {
                  model: root.ifaceStats(modelData)

                  delegate: Text {
                    x: Theme.networkDropdownEntryIndent
                    width: parent.width - Theme.networkDropdownEntryIndent
                    text: modelData
                    elide: Text.ElideRight
                    color: Theme.networkDropdownDimColor
                    font {
                      family: Theme.fontFamily
                      pixelSize: Theme.networkDropdownFontSize
                    }
                  }
                }
              }
            }
          }
        }

        EmptyRow {
          visible: root.ifaceOpen && NetInfo.interfaces.length === 0
          text: Theme.networkDropdownEmptyText
        }

        ActionRow {
          rowKey: "edit"
          icon: Theme.networkDropdownEditIcon
          label: Theme.networkDropdownEditText
          value: ""
          selected: root.selectedKey === "edit"
          onClicked: NetInfo.openEditor()
        }

        ActionRow {
          rowKey: "vpn"
          icon: Theme.networkDropdownVpnIcon
          label: Theme.networkDropdownVpnText
          value: NetInfo.vpnState !== ""
            ? NetInfo.vpnState + (NetInfo.vpnRelay !== "" ? "  " + NetInfo.vpnRelay : "")
            : Theme.networkDropdownEmptyText
          selected: root.selectedKey === "vpn"
          onClicked: NetInfo.openMullvad()
        }

        ToggleRow {
          rowKey: "randommac"
          icon: Theme.networkDropdownRandomMacIcon
          label: Theme.networkDropdownRandomMacText
          value: NetInfo.macRandom ? Theme.networkDropdownOnText : Theme.networkDropdownOffText
          highlight: NetInfo.macRandom
          selected: root.selectedKey === "randommac"
          onToggled: NetInfo.randomMac(!NetInfo.macRandom)
        }

        ToggleRow {
          rowKey: "monitor"
          icon: Theme.networkDropdownMonitorIcon
          label: Theme.networkDropdownMonitorText
          value: NetInfo.monitorOn ? Theme.networkDropdownOnText : Theme.networkDropdownOffText
          highlight: NetInfo.monitorOn
          selected: root.selectedKey === "monitor"
          onToggled: NetInfo.monitorMode(!NetInfo.monitorOn)
        }

        ListRow {
          rowKey: "ports"
          icon: Theme.networkDropdownPortsIcon
          label: Theme.networkDropdownPortsText
          value: NetInfo.portOpenCount + ""
          expanded: root.portsOpen
          selected: root.selectedKey === "ports"
          onClicked: root.portsOpen = !root.portsOpen
        }

        Repeater {
          model: root.portsOpen ? NetInfo.ports : []

          // loopback / external, then listening / outgoing / connection inside each, then the
          // sockets.
          delegate: Item {
            width: parent.width
            height: Theme.networkDropdownEntryRowHeight

            Text {
              visible: modelData.kind !== "socket"
              anchors {
                left: parent.left
                leftMargin: modelData.kind === "group" ? Theme.networkDropdownPortGroupIndent : Theme.networkDropdownPortSubIndent
                verticalCenter: parent.verticalCenter
              }
              text: modelData.text
              color: Theme.networkDropdownDimColor
              font {
                family: Theme.fontFamily
                pixelSize: Theme.networkDropdownLabelSize
                bold: modelData.kind === "group"
              }
            }

            Text {
              visible: modelData.kind !== "socket"
              anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
              }
              text: modelData.value
              color: Theme.networkDropdownDimColor
              font {
                family: Theme.fontFamily
                pixelSize: Theme.networkDropdownLabelSize
              }
            }

            EntryRow {
              visible: modelData.kind === "socket"
              x: Theme.networkDropdownPortItemIndent
              width: parent.width - Theme.networkDropdownPortItemIndent
              rowKey: "port-" + modelData.index
              text: modelData.text
              value: modelData.value
              selected: root.selectedKey === rowKey
              onClicked: root.selectedKey = rowKey
            }
          }
        }

        // Footer: tor and i2p daemons
        Item {
          width: parent.width
          height: Theme.networkDropdownSeparatorMargin * 2 + 1

          Rectangle {
            anchors {
              left: parent.left
              right: parent.right
              verticalCenter: parent.verticalCenter
            }
            height: 1
            color: Theme.networkDropdownSeparatorColor
          }
        }

        Repeater {
          model: NetInfo.daemons

          delegate: ActionRow {
            rowKey: "daemon-" + modelData.name
            icon: modelData.name === "tor"
              ? (modelData.running ? Theme.networkDropdownTorIcon : Theme.networkDropdownTorOffIcon)
              : (modelData.running ? Theme.networkDropdownI2pIcon : Theme.networkDropdownI2pOffIcon)
            iconColor: modelData.name === "tor" ? Theme.purple : Theme.yellow
            label: modelData.name === "tor" ? Theme.networkDropdownTorText : Theme.networkDropdownI2pText
            value: (modelData.running ? Theme.networkDropdownRunningText : Theme.networkDropdownStoppedText)
              + (modelData.ports.length > 0 ? "  " + modelData.ports.join(" ") : "")
            selected: root.selectedKey === rowKey
            onClicked: root.selectedKey = rowKey
          }
        }

        EmptyRow {
          visible: root.portsOpen && NetInfo.ports.length === 0
          text: Theme.networkDropdownNoPortsText
        }
      }
    }
  }
}
