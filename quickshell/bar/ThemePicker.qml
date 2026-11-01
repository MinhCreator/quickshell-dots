import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.widgets

// Floating panel at the center of the screen to choose light/dark and the color theme.
// Opens with:  qs ipc call theme toggle
// Arrows move (the theme is applied right away), Tab changes light/dark, 1-9 and 0 pick, Enter/Esc close.
Scope {
    id: root

    function screensToShow() {
        const all = Quickshell.screens
        const out = []
        for (let i = 0; i < all.length; i++)
            if (Compositor.focusedMonitor === "" || all[i].name === Compositor.focusedMonitor) out.push(all[i])
        return out.length > 0 ? out : all
    }

    Variants {
        model: Appearance.pickerOpen ? root.screensToShow() : []

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "shell-theme"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            readonly property int cols: 5
            property int sel: 0
            property real shown: 0

            Component.onCompleted: {
                for (let i = 0; i < Appearance.themes.length; i++)
                    if (Appearance.themes[i].id === Appearance.theme) sel = i
                intro.start()
                keys.forceActiveFocus()
            }

            NumberAnimation {
                id: intro
                target: win
                property: "shown"
                from: 0
                to: 1
                duration: 280
                easing.type: Easing.OutCubic
            }

            function go(i) {
                const n = Appearance.themes.length
                sel = ((i % n) + n) % n
                Appearance.setTheme(Appearance.themes[sel].id)
            }

            // outside the panel: click to close
            MouseArea {
                anchors.fill: parent
                onClicked: Appearance.pickerOpen = false
            }

            Item {
                id: keys
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) Appearance.pickerOpen = false
                    else if (event.key === Qt.Key_Left) win.go(win.sel - 1)
                    else if (event.key === Qt.Key_Right) win.go(win.sel + 1)
                    else if (event.key === Qt.Key_Up) win.go(win.sel - win.cols)
                    else if (event.key === Qt.Key_Down) win.go(win.sel + win.cols)
                    else if (event.key === Qt.Key_Tab || event.key === Qt.Key_M) Appearance.setMode("toggle")
                    else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) win.go(event.key - Qt.Key_1)
                    else if (event.key === Qt.Key_0) win.go(9)
                    else return
                    event.accepted = true
                }
            }

            ThemeCard {
                anchors.centerIn: parent
                sel: win.sel
                shown: win.shown
                onPicked: i => win.go(i)
                onModeClicked: m => Appearance.setMode(m)
            }
        }
    }
}
