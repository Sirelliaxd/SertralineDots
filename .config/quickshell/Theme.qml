pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Colors

    readonly property bool backgroundTransparency: true
    // -------
    readonly property color background: backgroundTransparency ? bgTs : bg
    readonly property color bg: "#14141c"
    readonly property color bgTs: "#80000000"
    readonly property color border: "#5f4c5f"
    readonly property color foreground: "#e6e6e8"
    readonly property color foregroundTransparent: "#50ffffff"
    readonly property color inactive: "#787c99"
    readonly property color red: "#f7768e"
    readonly property color blue: "#7aa2f7"
    readonly property color yellow: "#e0af68"
    readonly property color purple: "#bb9af7"
    readonly property color green: "#41a6b5"

    // Font
    readonly property int fontSize: 13
    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // -------

    // TaskBar
    readonly property real curveFlare: 28 // Higher -> softer
    readonly property real taskbarFlare: 30  // horizontal length of the bar's flare
    readonly property real pad: 12  // gap between bar content and its flare
    readonly property int barHeight: 30  // bar height
    readonly property int borderThickness: 12  // frame thickness around the screen
    // -------
    // App Launcher
    readonly property int appLauncherRecentsLength: 12  // how many recents are remembered
    readonly property int appLauncherMaxVisible: 7  // rows shown before the list scrolls
    readonly property int appLauncherItemHeight: 42  // height of one app row
    readonly property int appLauncherPanelWidth: 440  // panel width
    readonly property int appLauncherPanelHeight: 88  // height with no rows, search box only
    readonly property real appLauncherFlare: taskbarFlare  // bottom flare length, tracks the bar
    readonly property int appLauncherFlareHeight: 48  // bottom flare vertical radius
    readonly property int appLauncherHeightAnimDuration: 500  // open/close reveal duration, ms
    readonly property real appLauncherHeightAnimType: Easing.OutCubic  // reveal easing
    readonly property int appLauncherRadiusTop: 18  // top corner radius
    readonly property int appLauncherContentMargin: 12  // content inset from the body
    readonly property int appLauncherContentSpacing: 0  // spacing between the stacked parts
    readonly property int appLauncherDragWidth: 36  // drag handle width
    readonly property int appLauncherDragHeight: 4  // drag handle height
    readonly property int appLauncherDragRadius: 2  // drag handle radius
    readonly property int appLauncherContentItemWidth: 1  // spacer, currently unused
    readonly property int appLauncherContentItemHeigth: 8  // spacer, currently unused
    readonly property int appLauncherSearchBoxHeight: 44  // search box height
    readonly property int appLauncherSearchBoxRadius: 10  // search box radius
    readonly property int appLauncherSearchboxFocusBorderWidth: 1  // focus border width
    readonly property real appLauncherSearchBoxFocusOpacity: 0.55  // focus border opacity
    readonly property int appLauncherSearchBoxFocusAnimDuration: 150  // focus fade duration, ms
    readonly property int appLauncherSearchBoxRowMargin: 14  // search text left inset
    readonly property int appLauncherInvContSubsFromWidth: 40  // width kept beside the input
    readonly property string appLauncherSearchBoxText: "Search apps..."  // placeholder text
    readonly property real appLauncherSearchBoxTextOpacity: 0.28  // placeholder opacity
    readonly property int appLauncherSearchBoxTextSize: 13  // search text size, also the empty-state text
    readonly property int applauncherSpaceBtwnSearchAndApps: 8  // gap under the search box
    readonly property string appLauncherNoAppsFound: "No apps found"  // empty-list text
    readonly property real appLauncherNoAppsFoundOpacity: 0.28  // empty-list text opacity
    readonly property int appLauncherAppBgMargin: 2  // selection pill inset top and bottom
    readonly property int appLaucncherAppBgRadius: 10  // selection pill radius
    readonly property int appLauncherAppBgAnimDuration: 100  // selection pill fade, ms
    readonly property int appLauncherIconBubbleMargin: 8  // icon bubble inset left and right
    readonly property int appLauncherIconBubbleSpacing: 12  // gap between bubble and name
    readonly property int appLauncherIconBubbleSize: 36  // icon bubble size
    readonly property int appLauncherIconBubbleRadius: 9  // icon bubble radius
    readonly property int appLauncherIconBubbleAnimDuration: 100  // bubble fade, ms
    readonly property int appLauncherIconImgSize: 22  // icon image size
    readonly property int appLauncherIconImgFallbackTxtSize: 14  // letter shown when the icon is missing
    readonly property color appLauncherIconFallbackColorActive: foreground  // letter colour, selected row
    readonly property color appLauncherIconImgFallbackColorInactive: inactive  // letter colour, idle row
    readonly property int appLauncherIconFallbackAnimDuration: 100  // letter fade, ms
    readonly property int appLauncherAppNamesSpacing: 2  // gap between name and recent pill
    readonly property int appLauncherAppNamesFontSize: 13  // app name size
    readonly property color appLauncherAppNamesColorActive: foreground  // name colour, selected row
    readonly property int appLauncherAppNamesAnimDuration: 100  // name fade, ms
    readonly property int appLauncherRecentlyUsedSpacing: 6  // gap between pill and generic name
    readonly property int appLauncherRecentAppsWidthAddition: 8  // pill padding around its text
    readonly property int appLauncherRecentAppsHeight: 14  // pill height
    readonly property int appLauncherRecentAppsRadius: 4  // pill radius
    readonly property color appLauncherRecentlAppsColor: foreground  // pill fill
    readonly property string appLauncherRecentAppsText: "recent"  // pill label
    readonly property int appLauncherRecentAppsTxtSize: 9  // pill label size
    readonly property color appLauncherRecentAppsTxtColor: border  // pill label colour
    readonly property int appLauncherRecentsGenericTxtSize: 11  // generic-name size
    readonly property real appLauncherRecentsGenericTxtOpacity: 0.38  // generic-name opacity
    readonly property color appLauncherRecentsGenericTxtColor: border  // generic-name colour
    readonly property int appLauncherBottomItemWidth: 1  // bottom padding spacer
    readonly property int appLauncherBottomitemHeight: 4  // bottom padding spacer
    // -------
    // Power Dropdown
    readonly property string powerDropdownIcon: "\uf31f"      // Power menu topbar icon (artix logo)
    readonly property int powerDropdownPanelWidth: 200  // panel width
    readonly property int powerDropdownItemHeight: 40  // height of one entry
    readonly property int powerDropdownItemRadius: 10  // entry radius
    readonly property int powerDropdownContentMargin: 8  // content inset, also sets the panel height
    readonly property int powerDropdownMargin: 6       // gap to the frame and the bar
    readonly property int powerDropdownRadius: 14  // panel corner radius
    readonly property int powerDropdownIconBubbleSize: 28  // icon bubble size
    readonly property int powerDropdownIconBubbleRadius: 8  // icon bubble radius
    readonly property int powerDropdownIconSize: 15  // entry icon size
    readonly property int powerDropdownFontSize: 13  // entry label size
    readonly property int powerDropdownAnimDuration: 220  // open/close reveal duration, ms
    readonly property real powerDropdownAnimType: Easing.OutCubic  // reveal easing
    readonly property int menuUnloadGrace: 120       // time a menu outlives its close animation
    // -------
    // Volume Dropdown
    readonly property int volumeDropdownPanelWidth: 340  // panel width
    readonly property int volumeDropdownMargin: powerDropdownMargin  // same gap as the power menu
    readonly property int volumeDropdownRadius: powerDropdownRadius  // panel corner radius
    readonly property int volumeDropdownContentMargin: powerDropdownContentMargin  // content inset
    readonly property int volumeDropdownRowHeight: powerDropdownItemHeight  // height of one row
    readonly property int volumeDropdownRowRadius: powerDropdownItemRadius  // row highlight radius
    readonly property int volumeDropdownIconBubbleSize: powerDropdownIconBubbleSize  // icon bubble size
    readonly property int volumeDropdownIconBubbleRadius: powerDropdownIconBubbleRadius  // icon bubble radius
    readonly property int volumeDropdownIconSize: powerDropdownIconSize  // glyph size
    readonly property int volumeDropdownFontSize: powerDropdownFontSize  // row text size
    readonly property int volumeDropdownAnimDuration: powerDropdownAnimDuration  // reveal duration, ms
    readonly property real volumeDropdownAnimType: powerDropdownAnimType  // reveal easing
    readonly property int volumeDropdownLabelWidth: 62  // label column, after the bubble
    readonly property int volumeDropdownPercentWidth: 40  // percent column, at the right
    readonly property int volumeDropdownStreamSliderWidth: 110  // slider column of a stream row
    readonly property int volumeDropdownSliderHeight: 6  // slider track height
    readonly property int volumeDropdownSliderKnobSize: 12  // slider knob diameter
    readonly property int volumeDropdownDeviceRowHeight: 30  // one entry in a device list
    readonly property int volumeDropdownDeviceIndent: 38  // device list inset, under its bubble
    readonly property int volumeDropdownStreamSpacing: 2  // gap between stream rows
    readonly property int volumeDropdownMaxContentHeight: 420  // taller content scrolls instead
    readonly property real volumeDropdownKeyStep: 0.05  // left/right moves a level by this
    readonly property color volumeDropdownTrackColor: border  // slider track
    readonly property color volumeDropdownFillColor: foreground  // slider fill and knob
    readonly property color volumeDropdownDimColor: inactive  // device names, percent readout
    readonly property string volumeDropdownOutputText: "output"  // output level row label
    readonly property string volumeDropdownInputText: "input"  // input level row label
    readonly property string volumeDropdownStreamsText: "apps"  // per-stream section label
    readonly property string volumeDropdownNoStreamsText: "no streams"  // empty stream list
    readonly property string volumeDropdownOutputIcon: "󰕾"  // output level icon
    readonly property string volumeDropdownOutputMutedIcon: "󰝟"  // muted icon
    readonly property string volumeDropdownInputIcon: "󰍬"  // input level icon
    readonly property string volumeDropdownInputMutedIcon: "󰍭"  //  muted icon
    readonly property string volumeDropdownDeviceIcon: "󰓃"  // device rows icon
    readonly property string volumeDropdownStreamsIcon: "󰎆"  // stream row icon
    readonly property string volumeDropdownChevronClosed: "󰅀"  // list closed
    readonly property string volumeDropdownChevronOpen: "󰅃"  // list open
    // -------
    // Network Dropdown
    readonly property int networkDropdownPanelWidth: 400  // panel width
    readonly property int networkDropdownMargin: powerDropdownMargin  // same gap as the other menus
    readonly property int networkDropdownRadius: powerDropdownRadius  // panel corner radius
    readonly property int networkDropdownContentMargin: powerDropdownContentMargin  // content inset
    readonly property int networkDropdownRowHeight: powerDropdownItemHeight  // height of one row
    readonly property int networkDropdownRowRadius: powerDropdownItemRadius  // row highlight radius
    readonly property int networkDropdownIconBubbleSize: powerDropdownIconBubbleSize  // icon bubble size
    readonly property int networkDropdownIconBubbleRadius: powerDropdownIconBubbleRadius  // icon bubble radius
    readonly property int networkDropdownIconSize: powerDropdownIconSize  // glyph size
    readonly property int networkDropdownFontSize: powerDropdownFontSize  // row text size
    readonly property int networkDropdownAnimDuration: powerDropdownAnimDuration  // reveal duration, ms
    readonly property real networkDropdownAnimType: powerDropdownAnimType  // reveal easing
    readonly property int networkDropdownLabelWidth: 104  // label column, after the bubble
    readonly property int networkDropdownEntryRowHeight: 30  // one entry in a list
    readonly property int networkDropdownEntryIndent: 38  // list inset, under its bubble
    readonly property int networkDropdownNicHeight: 24  // the active interface line
    readonly property int networkDropdownSsidMax: 18  // longest network name drawn up there
    readonly property int networkDropdownChildIndent: 14  // inset of a dropdown's children
    readonly property int networkDropdownPortGroupIndent: 20  // loopback / external heading
    readonly property int networkDropdownPortSubIndent: 36  // listening / outgoing / connection
    readonly property int networkDropdownPortItemIndent: 52  // one socket
    readonly property int networkDropdownIfaceNameSize: 15  // interface name, bigger than a row
    readonly property int networkDropdownStatHeight: 46  // one cell of the info group
    readonly property int networkDropdownStatSpacing: 6  // gap between those cells
    readonly property int networkDropdownGroupPadding: 6  // inset of the info group bubble
    readonly property int networkDropdownLabelSize: 11  // the small label above a stat value
    readonly property int networkDropdownSeparatorMargin: 6  // space around the section divider
    readonly property color networkDropdownSeparatorColor: border  // the section divider
    readonly property int networkDropdownMaxContentHeight: volumeDropdownMaxContentHeight  // taller content scrolls
    readonly property int networkDropdownGraphHeight: 46  // network load graph
    readonly property int networkDropdownGraphSamples: 60  // samples kept, one per interval
    readonly property int networkDropdownGraphInterval: 1000  // sample interval, ms
    readonly property color networkDropdownGraphRxColor: blue  // download line
    readonly property color networkDropdownGraphTxColor: yellow  // upload line
    readonly property color networkDropdownGraphGridColor: border  // graph baseline
    readonly property color networkDropdownDimColor: inactive  // values, entry names, rates
    readonly property string networkDropdownText: "network"  // the connected network
    readonly property string networkDropdownLocalText: "local"  // local IPv4
    readonly property string networkDropdownPublicText: "public"  // public IPv4
    readonly property string networkDropdownWifiText: "wifi"  // radio toggle
    readonly property string networkDropdownNetworksText: "networks"  // scan list
    readonly property string networkDropdownConnectionsText: "connections"  // saved connections
    readonly property string networkDropdownEditText: "edit"  // connection editor
    readonly property string networkDropdownVpnText: "vpn"  // vpn state
    readonly property string networkDropdownRandomMacText: "random mac"  // MAC randomisation toggle
    readonly property string networkDropdownMonitorText: "monitor mode"  // wifi mode toggle
    readonly property string networkDropdownPortsText: "open ports"  // listening sockets
    readonly property string networkDropdownInterfacesText: "interfaces"  // interface list
    readonly property string networkDropdownLoadText: "load"  // throughput graph
    readonly property string networkDropdownRevealText: "show ip/mac"  // reveal the covered values
    readonly property string networkDropdownMaskChar: "•"  // Hidden ip/MAC char replacement
    readonly property string networkDropdownRescanText: "rescan"  // first entry of the scan list
    readonly property string networkDropdownNoNetworksText: "no networks"  // empty scan list
    readonly property string networkDropdownNoPortsText: "no listeners"  // empty port list
    readonly property string networkDropdownLoopbackText: "loopback"  // port group, 127.x and ::1
    readonly property string networkDropdownExternalText: "external"  // port group, everything else
    readonly property string networkDropdownListeningText: "listening"  // LISTEN / UNCONN sockets
    readonly property string networkDropdownOutgoingText: "outgoing"  // established, we started it
    readonly property string networkDropdownConnectionText: "connection"  // established, they did
    readonly property string networkDropdownTorText: "tor"  // footer daemon
    readonly property string networkDropdownI2pText: "i2p"  // footer daemon
    readonly property string networkDropdownRunningText: "running"  // daemon up
    readonly property string networkDropdownStoppedText: "stopped"  // daemon down
    readonly property string networkDropdownOnText: "on"  // toggle value
    readonly property string networkDropdownUpText: "up"  // interface carries a link
    readonly property string networkDropdownDownText: "down"  // it does not
    readonly property string networkDropdownOffText: "off"  // toggle value
    readonly property string networkDropdownEmptyText: "--"  // value while unknown
    readonly property string networkDropdownIcon: "󰖩"  // wifi, network row icon
    readonly property string networkDropdownIconOff: "󰖪"  // wifi off icon
    readonly property string networkDropdownLocalIcon: "󰩠"  // local address icon
    readonly property string networkDropdownPublicIcon: "󰖟"  // public address icon
    readonly property string networkDropdownMacIcon: "󰒋"  // interface icon
    readonly property string networkDropdownNetworksIcon: "󰑫"  // scan icon
    readonly property string networkDropdownConnectionsIcon: "󰌷"  // link icon
    readonly property string networkDropdownEditIcon: "󰏫"  // edit conncetions icon
    readonly property string networkDropdownVpnIcon: "󰒘"  // vpn icon
    readonly property string networkDropdownRandomMacIcon: "󰒝"  // randomise MAC icon
    readonly property string networkDropdownMonitorIcon: "󰈈"  // monitor mode icon
    readonly property string networkDropdownPortsIcon: "󰈀"  // ethernet icon
    readonly property string networkDropdownInterfacesIcon: "󰌗"  // interfaces row icon
    readonly property string networkDropdownIfaceOnIcon: "󰌘"  // connected interface icon
    readonly property string networkDropdownIfaceOffIcon: "󰌙"  // disconnected interface icon
    readonly property string networkDropdownTorIcon: "󰗹"  // tor connected icon
    readonly property string networkDropdownTorOffIcon: "󰁵"  // tor disconnected icon
    readonly property string networkDropdownI2pIcon: "󰊠"  // i2p connected icon
    readonly property string networkDropdownI2pOffIcon: "󰧵"  // i2p disconnected icon
    readonly property string networkDropdownLoadIcon: "󰄧"  // network load icon
    readonly property string networkDropdownRevealIcon: "󰈉"  // reveal ip/mac icon
    readonly property string networkDropdownLockIcon: "󰌾"  // secured network icon
    readonly property string networkDropdownChevronClosed: volumeDropdownChevronClosed  // list closed
    readonly property string networkDropdownChevronOpen: volumeDropdownChevronOpen  // list open

    // Bluetooth Dropdown
    readonly property int bluetoothDropdownPanelWidth: 400  // panel width
    readonly property int bluetoothDropdownMargin: networkDropdownMargin  // gap to the frame and the bar
    readonly property int bluetoothDropdownRadius: networkDropdownRadius  // panel corner radius
    readonly property int bluetoothDropdownContentMargin: networkDropdownContentMargin  // content inset
    readonly property int bluetoothDropdownRowHeight: networkDropdownRowHeight  // one row
    readonly property int bluetoothDropdownRowRadius: networkDropdownRowRadius  // row highlight radius
    readonly property int bluetoothDropdownIconBubbleSize: networkDropdownIconBubbleSize  // icon bubble
    readonly property int bluetoothDropdownIconBubbleRadius: networkDropdownIconBubbleRadius  // bubble radius
    readonly property int bluetoothDropdownIconSize: networkDropdownIconSize  // glyph size
    readonly property int bluetoothDropdownFontSize: networkDropdownFontSize  // row text
    readonly property int bluetoothDropdownLabelSize: networkDropdownLabelSize  // small labels
    readonly property int bluetoothDropdownLabelWidth: networkDropdownLabelWidth  // label column
    readonly property int bluetoothDropdownEntryRowHeight: networkDropdownEntryRowHeight  // one entry
    readonly property int bluetoothDropdownEntryIndent: networkDropdownEntryIndent  // entry text inset
    readonly property int bluetoothDropdownChildIndent: networkDropdownChildIndent  // children of a dropdown
    readonly property int bluetoothDropdownGroupPadding: networkDropdownGroupPadding  // info group inset
    readonly property int bluetoothDropdownStatHeight: networkDropdownStatHeight  // one info cell
    readonly property int bluetoothDropdownStatSpacing: networkDropdownStatSpacing  // gap between cells
    readonly property int bluetoothDropdownSeparatorMargin: networkDropdownSeparatorMargin  // divider space
    readonly property color bluetoothDropdownSeparatorColor: border  // the section divider
    readonly property color bluetoothDropdownDimColor: inactive  // values and entry names
    readonly property int bluetoothDropdownNicHeight: networkDropdownNicHeight  // the centred line
    readonly property int bluetoothDropdownNameMax: 22  // longest device or alias name drawn there
    readonly property int bluetoothDropdownDeviceNameSize: networkDropdownIfaceNameSize  // device name, bigger than a row
    readonly property int bluetoothDropdownDeviceLabelWidth: 185  // device name column, wider than a row label
    readonly property int bluetoothDropdownMaxContentHeight: networkDropdownMaxContentHeight  // taller content scrolls
    readonly property int bluetoothDropdownAnimDuration: networkDropdownAnimDuration  // reveal duration, ms
    readonly property real bluetoothDropdownAnimType: networkDropdownAnimType  // reveal easing
    // -------
    // Bluetooth Dropdown: strings
    readonly property string bluetoothDropdownAdapterText: "adapter"  // adapter id, e.g. hci0
    readonly property string bluetoothDropdownAliasText: "alias"  // what the adapter calls itself
    readonly property string bluetoothDropdownStateText: "state"  // enabled / disabled
    readonly property string bluetoothDropdownDevicesText: "devices"  // how many are paired
    readonly property string bluetoothDropdownPowerText: "power"  // adapter on/off
    readonly property string bluetoothDropdownPairableText: "pairable"  // accepts new pairings
    readonly property string bluetoothDropdownDiscoverableText: "discoverable"  // visible to others
    readonly property string bluetoothDropdownScanText: "scan"  // discovery list
    readonly property string bluetoothDropdownRescanText: "rescan"  // first entry of that list
    readonly property string bluetoothDropdownPairedText: "paired devices"  // section heading
    readonly property string bluetoothDropdownFoundText: "found"  // section heading, discovery
    readonly property string bluetoothDropdownConnectText: "connect"  // device action
    readonly property string bluetoothDropdownDisconnectText: "disconnect"  // device action
    readonly property string bluetoothDropdownTrustText: "trust"  // device action
    readonly property string bluetoothDropdownUntrustText: "untrust"  // device action
    readonly property string bluetoothDropdownPinText: "pin"  // device action, keep it on top
    readonly property string bluetoothDropdownUnpinText: "unpin"  // device action
    readonly property string bluetoothDropdownForgetText: "forget"  // device action, drops the pairing
    readonly property string bluetoothDropdownPairText: "pair"  // device action, on a found device
    readonly property string bluetoothDropdownOnText: "on"  // toggle value
    readonly property string bluetoothDropdownOffText: "off"  // toggle value
    readonly property string bluetoothDropdownEmptyText: "--"  // value while unknown
    readonly property string bluetoothDropdownNoDevicesText: "nothing paired"  // empty paired list
    readonly property string bluetoothDropdownNoneFoundText: "nothing found"  // empty discovery list
    readonly property string bluetoothDropdownConnectedText: "connected"  // device status
    readonly property string bluetoothDropdownTrustedText: "trusted"  // device status
    readonly property string bluetoothDropdownPinnedText: "pinned"  // device status
    readonly property string bluetoothDropdownNoAdapterText: "no adapter"  // no bluetooth hardware
    // -------
    // Bluetooth Dropdown: icons
    readonly property string bluetoothDropdownIcon: "󰂯"  // bt menu topbar icon
    readonly property string bluetoothDropdownOffIcon: "󰂲"  // bt disabled menu topbar icon
    readonly property string bluetoothDropdownAdapterIcon: "󰂳"  // settings icon
    readonly property string bluetoothDropdownDeviceIcon: "󰂱"  // unknown device icon
    readonly property string bluetoothDropdownHeadsetIcon: "󰋎"  // headset device icon
    readonly property string bluetoothDropdownHeadphonesIcon: "󰋋"  // hedphones device icon
    readonly property string bluetoothDropdownSpeakerIcon: "󰓃"  // speaker device icon
    readonly property string bluetoothDropdownKeyboardIcon: "󰌌"  // keyboard device icon
    readonly property string bluetoothDropdownMouseIcon: "󰍽"  // mouse device icon
    readonly property string bluetoothDropdownGamepadIcon: "󰊖"  // gamebad device icon
    readonly property string bluetoothDropdownPhoneIcon: "󰏲"  // phone device icon
    readonly property string bluetoothDropdownConnectIcon: "󰌷"  // connected icon
    readonly property string bluetoothDropdownDisconnectIcon: "󰌸"  // disconnected icon
    readonly property string bluetoothDropdownTrustIcon: "󰕥"  // trusted icon
    readonly property string bluetoothDropdownUntrustIcon: "󰕥"  // untrust icon
    readonly property string bluetoothDropdownPinIcon: "󰓒"  // pin icon
    readonly property string bluetoothDropdownUnpinIcon: "󰓑"  // unpin icon
    readonly property string bluetoothDropdownForgetIcon: "󰆴"  // delete icon
    readonly property string bluetoothDropdownPairIcon: "󰂱"  // pair icon
    readonly property string bluetoothDropdownScanIcon: "󰍉"  // scan icon
    readonly property string bluetoothDropdownPowerIcon: "󰒓"  // power icon
    readonly property string bluetoothDropdownBatteryIcon: "󰁹" // battery icon
    readonly property color bluetoothDropdownPinnedColor: yellow  // the star on a pinned device
    readonly property string bluetoothDropdownChevronClosed: volumeDropdownChevronClosed  // list closed
    readonly property string bluetoothDropdownChevronOpen: volumeDropdownChevronOpen  // list open
}
