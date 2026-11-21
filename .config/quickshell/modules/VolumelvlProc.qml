//credit @tony
// https://www.youtube.com/watch?v=g_I4hwCuDyQ
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import "root:/"

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [root.sink]
    }

    readonly property bool ready: !!sink && sink.ready && !!sink.audio
    readonly property bool muted: ready && sink.audio.muted

    readonly property int volumeLevel: ready ? Math.round(sink.audio.volume * 100) : 0

    readonly property string icon: {
        if (!ready)
            return "󰓄 ";
        if (muted || volumeLevel === 0)
            return " ";

        if (volumeLevel >= 67)
            return " ";
        if (volumeLevel >= 34)
            return " ";
        if (volumeLevel < 34)
            return " ";
        return "󰓃";
    }

    property string barTxt: icon + volumeLevel + "%"
}
