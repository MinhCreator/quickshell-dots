import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.widgets

Scope {
    id: root

    property string kind: "volume"     // volume | brightness
    property bool shown: false
    property bool armed: false         // evita l'OSD ai primi caricamenti

    readonly property real value: kind === "volume" ? (Audio.muted ? 0 : Math.min(1, Audio.volume))
                                                    : Brightness.percent

    function show(k) {
        if (!armed || UiState.controlOpen || Lid.recent) return
        kind = k
        shown = true
        hideTimer.restart()
    }

    Timer { interval: 2000; running: true; onTriggered: root.armed = true }
    Timer { id: hideTimer; interval: 1500; onTriggered: root.shown = false }

    Connections {
        target: Audio
        function onVolumeChanged() { root.show("volume") }
        function onMutedChanged()  { root.show("volume") }
    }

    Connections {
        target: Brightness
        function onPercentChanged() { root.show("brightness") }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData

            anchors { right: true }
            margins { right: 10 }

            implicitWidth: 64
            implicitHeight: 230
            color: "transparent"
            visible: root.shown || pill.opacity > 0

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "shell-osd"

            // Clicks pass through: the OSD is informational only
            mask: Region {}

            Rectangle {
                id: pill

                anchors.verticalCenter: parent.verticalCenter
                x: root.shown ? parent.width - width - 4 : parent.width + 4
                width: 46
                height: 210
                radius: 23
                color: Theme.island
                border.width: 1
                border.color: Theme.border
                opacity: root.shown ? 1 : 0

                Behavior on x       { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 14
                    text: Math.round(root.value * 100) + "%"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    id: track
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 40
                    width: 8
                    height: parent.height - 40 - 48
                    radius: 4
                    color: Theme.border

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Math.max(width, parent.height * root.value)
                        radius: 4
                        color: Theme.accent
                        Behavior on height { NumberAnimation { duration: 80 } }
                    }
                }

                Glyph {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height - 14 - height
                    kind: root.kind === "volume" ? "volume" : "sun"
                    level: (root.kind === "volume" && Audio.muted) ? 0 : (root.value > 0.5 ? 2 : 1)
                    size: 18
                    color: Theme.foreground
                }
            }
        }
    }
}
