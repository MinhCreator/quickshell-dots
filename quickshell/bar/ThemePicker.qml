import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.widgets

// Floating panel at the center of the screen to choose light/dark and the color theme.
// Opens with:  qs ipc call theme toggle
// Type to search, arrows browse (previewed live), Tab changes light/dark, Enter applies, Esc cancels.
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

            property int sel: 0
            property real shown: 0
            property string query: ""
            property string original: Appearance.theme

            readonly property var list: {
                const q = query.toLowerCase()
                if (q === "") return Appearance.themes
                return Appearance.themes.filter(t => t.name.toLowerCase().indexOf(q) >= 0 || t.id.indexOf(q) >= 0 || t.hint.toLowerCase().indexOf(q) >= 0)
            }

            Component.onCompleted: {
                original = Appearance.theme
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
                const n = list.length
                if (n === 0) return
                sel = ((i % n) + n) % n
                Appearance.setTheme(list[sel].id)
            }

            function close(keep) {
                if (!keep) Appearance.setTheme(original)
                Appearance.pickerOpen = false
            }

            // outside the panel: click to close
            MouseArea {
                anchors.fill: parent
                onClicked: win.close(true)
            }

            Item {
                id: keys
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        if (win.query !== "") { win.query = ""; win.sel = 0 }
                        else win.close(false)
                    }
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) win.close(true)
                    else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) win.go(win.sel - 1)
                    else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) win.go(win.sel + 1)
                    else if (event.key === Qt.Key_Tab) Appearance.setMode("toggle")
                    else if (event.key === Qt.Key_Backspace) { win.query = win.query.slice(0, -1); win.sel = 0 }
                    else if (event.text.length === 1 && event.text >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) { win.query += event.text; win.sel = 0 }
                    else return
                    event.accepted = true
                }
            }

            ThemeCard {
                anchors.centerIn: parent
                items: win.list
                sel: win.sel
                query: win.query
                shown: win.shown
                onPicked: i => win.go(i)
                onModeClicked: m => Appearance.setMode(m)
            }
        }
    }
}
