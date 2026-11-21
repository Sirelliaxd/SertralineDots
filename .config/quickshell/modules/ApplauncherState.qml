pragma Singleton

import QtQuick
import QtCore
import Quickshell
import "root:/"

Singleton {
    id: root

    property bool launcherVisible: false
    property var recentIds: []
    property int recentsLength: Theme.appLauncherRecentsLength

    property var _settings: Settings {
        category: "AppLauncher"
        location: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/quickshell/applauncher.ini"
        property string recentIdsSerialized: "[]"
    }

    Component.onCompleted: {
        recentIds = JSON.parse(_settings.recentIdsSerialized);
    }

    function toggle() {
        launcherVisible = !launcherVisible;
    }
    function show() {
        launcherVisible = true;
    }
    function hide() {
        launcherVisible = false;
    }

    function recordLaunch(id) {
        var list = recentIds.slice(); // copy of current recent IDs
        var idx = list.indexOf(id);  // check if requested app is already in list

        if (idx !== -1)
            list.splice(idx, 1);  // if exists, remove from current position
        list.unshift(id);  // add app to the top

        if (list.length > recentsLength)
            list = list.slice(0, recentsLength); // keep only 12 (default value) most recent apps

        // update UI and save to disk
        recentIds = list;
        _settings.recentIdsSerialized = JSON.stringify(list);
    }

    function clearRecents() {
        recentIds = [];
        _settings.recentIdsSerialized = "[]";
    }
}
