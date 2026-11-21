pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import "root:/"

// Everything the network menu reads. Quickshell's Networking service covers the live parts
// (devices, their networks, the wifi radio), and the rest is shelled out: `nmcli` for
// scanning and for the saved connections, `ip` for addresses and MACs, `ss` for the
// listening sockets, `curl` for the public address and `mullvad` for the VPN state.
//
// Every read is a Process started by refresh(), which the menu calls when it opens, so
// nothing polls while the menu is closed. The processes below are separate so a refresh
// cannot cancel an action that is still running (or the other way around).
Singleton {
    id: root

    // ---- live, from the Networking service, no polling involved
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired && d.connected)
    readonly property var activeWifi: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property string wifiName: wifiDevice ? wifiDevice.name : ""
    readonly property string wiredName: wiredDevice ? wiredDevice.name : ""
    readonly property int wifiSignal: activeWifi ? Math.round(activeWifi.signalStrength * 100) : 0
    readonly property string ssid: activeWifi ? activeWifi.name : ""

    // The interface the load graph samples, and the name of what is connected right now.
    readonly property string activeInterface: wiredName !== "" ? wiredName : wifiName
    readonly property string connectedName: wiredName !== "" ? wiredName : (activeWifi ? activeWifi.name : "")
    readonly property bool connected: connectedName !== ""

    // ---- shelled out
    property var wifiNetworks: []  // { ssid, signal, security, secured, active }
    property var connections: []   // { name, type, device, active }
    property var interfaces: []    // { name, connected, up, ip, mac, linkKind, stats }
    property var links: []         // { device, mac, random }
    property var addresses: []     // { device, address }
    property var ports: []         // display rows: { kind, text, value, index }
    property var sockets: []       // every socket, before it is grouped
    property var listeningPorts: []  // what something listens on, used to classify the rest
    readonly property int portOpenCount: sockets.filter(s => s.listening).length
    property string publicIp: ""
    property var publicIpTime: 0
    property string vpnState: ""
    property string vpnRelay: ""
    property string wifiMode: ""  // managed, monitor, ...
    property bool torRunning: false
    property bool i2pRunning: false
    property bool wifiRetried: false

    readonly property var activeLink: links.find(l => l.device === activeInterface) || (links.length > 0 ? links[0] : null)
    readonly property bool macRandom: activeLink ? activeLink.random : false
    readonly property bool monitorOn: wifiMode === "monitor"
    readonly property bool vpnConnected: vpnState === "Connected"

    readonly property string localAddress: {
        var own = root.addressOf(root.activeInterface);
        if (own !== "")
            return own;
        return root.addresses.length > 0 ? root.addresses[0].address : "";
    }

    function addressOf(device) {
        var found = root.addresses.find(a => a.device === device);
        return found ? found.address : "";
    }

    // ---- interfaces, straight out of `ip -j addr`
    function refreshInterfaces() {
        if (ifaceProc.running)
            return;
        ifaceProc.running = true;
    }

    function parseInterfaces(text) {
        var list = [];
        try {
            var devs = JSON.parse(text);
            for (var i = 0; i < devs.length; i++) {
                var d = devs[i];
                var flags = d.flags || [];
                var ip = "";
                var global = false;
                var lines = ["mtu " + d.mtu + "  qdisc " + d.qdisc + "  txqlen " + d.txqlen, "state " + d.operstate + "  link_type " + d.link_type, "flags " + flags.join(",")];
                var info = d.addr_info || [];
                for (var j = 0; j < info.length; j++) {
                    var a = info[j];
                    if (ip === "" && a.family === "inet")
                        ip = a.local;
                    if (a.scope === "global")
                        global = true;
                    lines.push(a.family + " " + a.local + "/" + a.prefixlen + (a.scope ? "  scope " + a.scope : "") + (a.dynamic ? " dynamic" : ""));
                }
                var up = flags.indexOf("LOWER_UP") >= 0;
                list.push({
                    name: d.ifname,
                    connected: up && global,
                    up: up,
                    ip: ip,
                    mac: (d.address || "").toLowerCase(),
                    linkKind: d.link_type,
                    stats: lines
                });
            }
        } catch (e) {
            // `ip` prints nothing parseable when it fails
        }
        interfaces = list;
    }

    // nmcli -t escapes the separators inside a field, so "a\:b" is one field containing "a:b"
    function splitCols(line) {
        var out = [];
        var cur = "";
        for (var i = 0; i < line.length; i++) {
            var ch = line[i];
            if (ch === "\\" && line[i + 1] === ":") {
                cur += ":";
                i++;
            } else if (ch === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += ch;
            }
        }
        out.push(cur);
        return out;
    }

    // The second-least-significant bit of the first octet marks a locally administered
    // (randomised) address, which is what macchanger -r sets.
    function isRandom(mac) {
        return (parseInt(mac.substring(0, 2), 16) & 0x02) !== 0;
    }

    function isVirtual(name) {
        return /^(lo|virbr|docker|veth|br-|tun|tap|wg)/.test(name);
    }

    function refresh() {
        refreshInterfaces();
        refreshWifi();
        refreshConnections();
        refreshLinks();
        refreshAddresses();
        refreshPorts();
        refreshDaemons();
        refreshVpn();
        refreshMode();
        refreshPublicIp();
    }

    // ---- wifi scan
    function refreshWifi() {
        if (wifiProc.running)
            return;
        wifiNetworks = [];
        wifiProc.running = true;
    }

    function addWifi(line) {
        var f = root.splitCols(line);
        if (f.length < 4)
            return;
        var ssid = f[1];
        if (ssid === "")
            return;

        var entry = {
            ssid: ssid,
            signal: parseInt(f[2]) || 0,
            security: f[3],
            secured: f[3] !== "" && f[3] !== "--",
            active: f[0].trim() === "*"
        };
        var list = root.wifiNetworks.slice();
        var idx = list.findIndex(n => n.ssid === entry.ssid);
        if (idx < 0) {
            list.push(entry);
        } else if (list[idx].signal >= entry.signal) {
            list[idx].active = list[idx].active || entry.active;
        } else {
            entry.active = entry.active || list[idx].active;
            list[idx] = entry;
        }
        root.wifiNetworks = list;
    }

    function rescan() {
        if (rescanProc.running)
            return;
        rescanProc.running = true;
        rescanWait.start();
    }

    // ---- saved connections
    function refreshConnections() {
        if (connProc.running)
            return;
        connections = [];
        connProc.running = true;
    }

    // ---- interfaces and addresses
    function refreshLinks() {
        if (linkProc.running)
            return;
        links = [];
        linkProc.running = true;
    }

    function refreshAddresses() {
        if (addrProc.running)
            return;
        addresses = [];
        addrProc.running = true;
    }

    // ---- sockets, every state, arranged as the display tree
    // `ss -tuanp` rather than `-tulnp`: the outgoing and accepted connections are half the point of
    // the list. The flat array below is what the menu draws, one entry per line, `kind` saying how
    // deep it sits: a group (loopback / external), a subgroup (listening / outgoing / connection),
    // or one socket.
    function refreshPorts() {
        if (portProc.running)
            return;
        ports = [];
        sockets = [];
        listeningPorts = [];
        portProc.running = true;
    }

    // "127.0.0.1:9050", "[::1]:631", "0.0.0.0%virbr0:67", "[fe80::1]%wlan0:546"
    function portHost(field) {
        var cut = field.lastIndexOf(":");
        var host = cut < 0 ? field : field.substring(0, cut);
        return host.replace(/^\[/, "").replace(/\]$/, "").split("%")[0];
    }

    function portNumber(field) {
        var cut = field.lastIndexOf(":");
        return cut < 0 ? "" : field.substring(cut + 1);
    }

    function isLoopback(host) {
        return host === "::1" || host.indexOf("127.") === 0;
    }

    // A socket that is not listening but sits on a port something is listening on is a connection
    // somebody made to us; anything else established is outgoing.
    function isIncoming(sock) {
        return listeningPorts.indexOf(parseInt(sock.port, 10)) >= 0;
    }

    function addPort(line) {
        var f = line.trim().split(/\s+/);
        if (f.length < 6)
            return;
        var who = f.slice(6).join(" ").match(/\("([^"]+)"/);
        var local = f[4];
        var state = f[1];
        var sock = {
            proto: f[0],
            state: state,
            host: portHost(local),
            port: portNumber(local),
            address: local,
            peer: f[5],
            process: who ? who[1] : "",
            listening: state === "LISTEN" || (state === "UNCONN" && parseInt(portNumber(local), 10) < 32768)
        };
        if (sock.listening && sock.port !== "") {
            var known = listeningPorts.slice();
            if (known.indexOf(parseInt(sock.port, 10)) < 0)
                known.push(parseInt(sock.port, 10));
            listeningPorts = known;
        }
        var list = sockets.slice();
        list.push(sock);
        sockets = list;
        rebuildPorts();
    }

    // Groups first, then the three states inside each, the sockets last. Empty branches are left out.
    function rebuildPorts() {
        var out = [];
        var groups = [
            {
                name: Theme.networkDropdownLoopbackText,
                test: s => isLoopback(s.host)
            },
            {
                name: Theme.networkDropdownExternalText,
                test: s => !isLoopback(s.host)
            }
        ];
        var states = [
            {
                name: Theme.networkDropdownListeningText,
                test: s => s.listening
            },
            {
                name: Theme.networkDropdownOutgoingText,
                test: s => !s.listening && !isIncoming(s)
            },
            {
                name: Theme.networkDropdownConnectionText,
                test: s => !s.listening && isIncoming(s)
            }
        ];
        for (var g = 0; g < groups.length; g++) {
            var inGroup = sockets.filter(groups[g].test);
            if (inGroup.length === 0)
                continue;
            out.push({
                kind: "group",
                text: groups[g].name,
                value: inGroup.length + ""
            });
            for (var t = 0; t < states.length; t++) {
                var rows = inGroup.filter(states[t].test);
                if (rows.length === 0)
                    continue;
                out.push({
                    kind: "sub",
                    text: states[t].name,
                    value: rows.length + ""
                });
                for (var i = 0; i < rows.length; i++) {
                    var row = {
                        kind: "socket",
                        text: rows[i].proto + "  " + rows[i].address,
                        value: rows[i].process !== "" ? rows[i].process : rows[i].state.toLowerCase()
                    };
                    out.push(row);
                }
            }
        }
        for (var k = 0; k < out.length; k++)
            out[k].index = k;
        ports = out;
    }

    // ---- tor and i2p
    // The process check works for any user's process (tor runs as the tor user), the ports come out
    // of the socket list above matched against each daemon's known ports, so "active" means the
    // daemon is up and something is actually listening for it.
    function refreshDaemons() {
        torRunning = false;
        i2pRunning = false;
        torProc.running = true;
        i2pProc.running = true;
    }

    readonly property var daemonPorts: {
        var tor = [9001, 9030, 9040, 9050, 9051, 9150];
        var i2p = [4444, 4445, 7654, 7656, 7657, 6668];
        return {
            tor: listeningPorts.filter(p => tor.indexOf(p) >= 0).sort((a, b) => a - b),
            i2p: listeningPorts.filter(p => i2p.indexOf(p) >= 0).sort((a, b) => a - b)
        };
    }

    readonly property var daemons: [
        {
            name: "tor",
            running: torRunning,
            ports: daemonPorts.tor
        },
        {
            name: "i2p",
            running: i2pRunning,
            ports: daemonPorts.i2p
        }
    ]

    // ---- VPN
    function refreshVpn() {
        if (vpnProc.running)
            return;
        vpnState = "";
        vpnRelay = "";
        vpnProc.running = true;
    }

    // ---- wifi mode (managed / monitor)
    function refreshMode() {
        if (modeProc.running || wifiName === "")
            return;
        wifiMode = "";
        modeProc.running = true;
    }

    // ---- public address, at most once a minute
    function refreshPublicIp() {
        if (pubProc.running)
            return;
        if (publicIp !== "" && Date.now() - publicIpTime < 60000)
            return;
        pubProc.running = true;
    }

    // ---- actions. Every command is an argv array, never a shell string
    function setWifiEnabled(on) {
        Networking.wifiEnabled = on;
    }

    function connectWifi(ssid) {
        connectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    function activate(name) {
        upProc.command = ["nmcli", "connection", "up", name];
        upProc.running = true;
    }

    function openEditor() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }

    function openMullvad() {
        Quickshell.execDetached(["mullvad-vpn"]);
    }

    // macchanger -r randomises the address, -p puts the permanent one back. It takes the
    // interface down and up, so the connection drops and comes back with the new address.
    function macCommand(on) {
        if (!activeLink)
            return [];
        return ["pkexec", "macchanger", on ? "-r" : "-p", activeLink.device];
    }

    // iw switches the interface between managed and monitor; only drivers that list monitor
    // in their supported modes accept it, and the connection drops while it is in monitor mode.
    function monitorCommand(on) {
        if (wifiName === "")
            return [];
        return ["pkexec", "iw", "dev", wifiName, "set", "type", on ? "monitor" : "managed"];
    }

    // Needs root: pkexec raises the polkit prompt.
    function randomMac(on) {
        var cmd = macCommand(on);
        if (cmd.length === 0 || macProc.running)
            return;
        macProc.command = cmd;
        macProc.running = true;
    }

    // Needs root, and only works on an interface whose driver supports monitor mode.
    function monitorMode(on) {
        var cmd = monitorCommand(on);
        if (cmd.length === 0 || modeSetProc.running)
            return;
        modeSetProc.command = cmd;
        modeSetProc.running = true;
    }

    // ---- reads
    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        stdout: SplitParser {
            onRead: data => root.addWifi(data)
        }
        onRunningChanged: {
            if (running)
                return;
            root.wifiNetworks = root.wifiNetworks.slice().sort((a, b) => b.signal - a.signal);
            // nmcli answers with nothing while it is still scanning, so an empty first answer gets
            // one retry. wifiRetried keeps that from turning into a loop.
            if (root.wifiNetworks.length === 0 && !root.wifiRetried) {
                root.wifiRetried = true;
                wifiRetry.start();
            } else {
                root.wifiRetried = false;
            }
        }
    }

    Timer {
        id: wifiRetry
        interval: 2500
        onTriggered: root.refreshWifi()
    }

    Process {
        id: connProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE,ACTIVE", "connection", "show"]
        stdout: SplitParser {
            onRead: data => {
                var f = root.splitCols(data);
                if (f.length < 4)
                    return;
                var list = root.connections.slice();
                list.push({
                    name: f[0],
                    type: f[1],
                    device: f[2],
                    active: f[3] === "yes"
                });
                root.connections = list;
            }
        }
    }

    Process {
        id: ifaceProc
        command: ["ip", "-j", "addr"]
        stdout: StdioCollector {
            onStreamFinished: root.parseInterfaces(text)
        }
    }

    Process {
        id: linkProc
        command: ["ip", "-br", "link"]
        stdout: SplitParser {
            onRead: data => {
                var f = data.trim().split(/\s+/);
                if (f.length < 3 || root.isVirtual(f[0]) || !/^([0-9a-f]{2}:){5}[0-9a-f]{2}$/.test(f[2]))
                    return;
                if (f[1] !== "UP")
                    return;
                var list = root.links.slice();
                list.push({
                    device: f[0],
                    mac: f[2],
                    random: root.isRandom(f[2])
                });
                root.links = list;
            }
        }
    }

    Process {
        id: addrProc
        command: ["ip", "-4", "-o", "addr", "show"]
        stdout: SplitParser {
            onRead: data => {
                var f = data.trim().split(/\s+/);
                if (f.length < 4 || f[2] !== "inet" || root.isVirtual(f[1]))
                    return;
                var list = root.addresses.slice();
                list.push({
                    device: f[1],
                    address: f[3].split("/")[0]
                });
                root.addresses = list;
            }
        }
    }

    Process {
        id: portProc
        command: ["ss", "-H", "-tuanp"]
        stdout: SplitParser {
            onRead: data => root.addPort(data)
        }
    }

    Process {
        id: torProc
        command: ["pgrep", "-x", "tor"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "")
                    root.torRunning = true;
            }
        }
    }

    Process {
        id: i2pProc
        command: ["pgrep", "-f", "i2pd|i2prouter|i2p\\.jar"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "")
                    root.i2pRunning = true;
            }
        }
    }

    Process {
        id: vpnProc
        command: ["mullvad", "status"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (root.vpnState === "")
                    root.vpnState = line;
                else if (line.indexOf("Relay:") === 0)
                    root.vpnRelay = line.substring(6).trim().split(" ")[0];
            }
        }
    }

    Process {
        id: modeProc
        command: ["iw", "dev", root.wifiName, "info"]
        stdout: SplitParser {
            onRead: data => {
                var f = data.trim().split(/\s+/);
                if (f[0] === "type")
                    root.wifiMode = f[1];
            }
        }
    }

    Process {
        id: pubProc
        command: ["curl", "-s", "--max-time", "5", "https://api.ipify.org"]
        stdout: SplitParser {
            onRead: data => {
                var ip = data.trim();
                if (ip !== "") {
                    root.publicIp = ip;
                    root.publicIpTime = Date.now();
                }
            }
        }
    }

    // ---- actions that run a command
    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
    }

    Timer {
        id: rescanWait
        interval: 4000
        onTriggered: root.refreshWifi()
    }

    Process {
        id: connectProc
    }

    Process {
        id: upProc
    }

    Process {
        id: macProc
        onRunningChanged: if (!running)
            root.refreshLinks()
    }

    Process {
        id: modeSetProc
        onRunningChanged: if (!running)
            root.refreshMode()
    }
}
