pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ---- pywal palette (~/.cache/wal/colors.json), updates by itself ----
    FileView {
        id: walFile
        path: Quickshell.env("HOME") + "/.cache/wal/colors.json"
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: pal

            property JsonObject special: JsonObject {
                property string background: "#0d0d0d"
                property string foreground: "#e6e6e6"
            }
            property JsonObject colors: JsonObject {
                property string color1: "#e06c75"
                property string color2: "#98c379"
                property string color3: "#e5c07b"
                property string color4: "#3ecfa8"
                property string color5: "#c678dd"
                property string color6: "#56b6c2"
                property string color8: "#5c6370"
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: walFile.reload()
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t,
                       a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t, 1)
    }

    // ---- Colori semantici ----
    readonly property color background: pal.special.background
    readonly property color foreground: pal.special.foreground
    readonly property color accent:     pal.colors.color4   // change the number for another accent
    readonly property color note:       pal.colors.color5   // days with notes
    readonly property color muted:      mix(background, foreground, 0.45)
    readonly property color danger:     pal.colors.color1

    readonly property color island:       mix(background, Qt.rgba(0, 0, 0, 1), 0.5)
    readonly property color islandHover:  mix(island, foreground, 0.10)
    readonly property color surfaceSoft:  mix(island, foreground, 0.06)
    readonly property color border:       mix(island, foreground, 0.10)

    // ---- Dimensioni ----
    readonly property int islandHeight: 34
    readonly property int gap:          8
    readonly property int padding:      14
    readonly property int topMargin:    6
    readonly property int weekStart:    1   // 1 = Monday, 0 = Sunday (as in the video)

    // ---- Font ----
    readonly property string fontFamily: Qt.application.font.family
    readonly property int    fontSize:   13
}
