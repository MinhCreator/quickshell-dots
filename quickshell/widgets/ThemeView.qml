import QtQuick
import qs.theme

// The theme selector: it lives inside the pill (Island / Classic / Dashboard) or the side panel (Vertical).
// Dark|Light on top, search box, carousel of themes, hints.
// Type to search, arrows browse (previewed live), Tab light/dark, Enter applies, Esc cancels.
Item {
    id: root

    property string query: ""
    property int sel: 0
    property string original: "classic"

    readonly property var items: {
        const q = query.toLowerCase()
        if (q === "") return Appearance.themes
        return Appearance.themes.filter(t => t.name.toLowerCase().indexOf(q) >= 0 || t.id.indexOf(q) >= 0 || t.hint.toLowerCase().indexOf(q) >= 0)
    }

    implicitWidth: 700
    implicitHeight: 232

    function reset() {
        query = ""
        original = Appearance.theme
        sel = 0
        for (let i = 0; i < Appearance.themes.length; i++)
            if (Appearance.themes[i].id === Appearance.theme) sel = i
        keys.forceActiveFocus()
    }

    function go(i) {
        const n = items.length
        if (n === 0) return
        sel = ((i % n) + n) % n
        Appearance.setTheme(items[sel].id)
    }

    function close(keep) {
        if (!keep) Appearance.setTheme(original)
        Appearance.pickerOpen = false
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (root.query !== "") { root.query = ""; root.sel = 0 }
                else root.close(false)
            }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.close(true)
            else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) root.go(root.sel - 1)
            else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) root.go(root.sel + 1)
            else if (event.key === Qt.Key_Tab) Appearance.setMode("toggle")
            else if (event.key === Qt.Key_Backspace) { root.query = root.query.slice(0, -1); root.sel = 0 }
            else if (event.text.length === 1 && event.text >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) { root.query += event.text; root.sel = 0 }
            else return
            event.accepted = true
        }
    }

    Item {
        id: card
        anchors.fill: parent

        // ---- Dark | Light (above everything) ----
        Rectangle {
            id: seg
            anchors.horizontalCenter: parent.horizontalCenter
            y: 14
            width: 190; height: 32
            radius: 16
            color: Theme.surfaceSoft
            border.width: 1
            border.color: Theme.border

            Rectangle {
                width: parent.width / 2 - 4; height: parent.height - 8
                y: 4
                x: Appearance.mode === "dark" ? 4 : parent.width / 2
                radius: 12
                color: Theme.accent
                Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            }
            Row {
                anchors.fill: parent
                Repeater {
                    model: [ { id: "dark", label: "Dark" }, { id: "light", label: "Light" } ]
                    delegate: Item {
                        required property var modelData
                        width: seg.width / 2; height: seg.height
                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            color: Appearance.mode === parent.modelData.id ? Theme.island : Theme.muted
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (Appearance.mode !== parent.modelData.id) Appearance.setMode(parent.modelData.id)
                        }
                    }
                }
            }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 24
            y: 22
            visible: Appearance.applying
            text: "Repainting…"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

        // ---- Search ----
        Item {
            id: search
            x: 24; y: 58
            width: parent.width - 48; height: 30

            Rectangle {   // magnifier
                x: 2; y: 6
                width: 13; height: 13; radius: 6.5
                color: "transparent"
                border.width: 1.6
                border.color: Theme.muted
            }
            Rectangle {
                x: 13; y: 17
                width: 6; height: 1.8; radius: 1
                rotation: 45
                color: Theme.muted
            }
            Text {
                x: 30
                anchors.verticalCenter: parent.verticalCenter
                text: root.query.length > 0 ? root.query : "Search themes..."
                color: root.query.length > 0 ? Theme.foreground : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }
            Rectangle {   // caret
                x: 30 + (root.query.length > 0 ? queryWidth.width : 0) + 1
                anchors.verticalCenter: parent.verticalCenter
                width: 1.5; height: 18
                color: Theme.accent
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0; duration: 500 }
                    NumberAnimation { to: 1; duration: 500 }
                }
            }
            Text {
                id: queryWidth
                visible: false
                text: root.query
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: (root.items.length === 0 ? 0 : root.sel + 1) + "/" + root.items.length
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }

        // ---- Carousel ----
        Item {
            id: strip
            x: 0; y: 98
            width: parent.width; height: 92
            clip: true

            Repeater {
                model: root.items
                delegate: Rectangle {
                id: opt

                required property var modelData
                required property int index

                readonly property var pv: Theme.preview(modelData.id)
                readonly property bool chosen: root.sel === index
                readonly property bool current: Appearance.theme === modelData.id

                width: 190
                height: 84
                y: 4
                x: (strip.width - width) / 2 + (index - root.sel) * (width + 14)
                Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                radius: 16
                color: optMouse.containsMouse ? Theme.islandHover : Theme.surfaceSoft
                border.width: chosen ? 2 : 0
                border.color: Theme.accent
                opacity: chosen ? 1 : 0.62
                Behavior on opacity { NumberAnimation { duration: 140 } }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 20
                    spacing: 7
                    Repeater {
                        model: [ opt.pv.accent, opt.pv.note, opt.pv.danger, opt.pv.foreground, opt.pv.muted, opt.pv.background ]
                        delegate: Rectangle {
                            required property var modelData
                            width: 14; height: 14; radius: 7
                            color: modelData
                            border.width: 1
                            border.color: Theme.border
                        }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 52
                    text: opt.modelData.name.toLowerCase()
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: opt.chosen
                }
                Rectangle {   // dot: theme in use
                    visible: opt.current
                    x: parent.width - 16; y: 8
                    width: 6; height: 6; radius: 3
                    color: Theme.accent
                }

                MouseArea {
                    id: optMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.go(opt.index); keys.forceActiveFocus() }
                }
            }
            }
        }

        Text {
            anchors.centerIn: strip
            visible: root.items.length === 0
            text: "No theme matches"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 13
        }

        // ---- Footer ----
        Text {
            x: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            text: "← →  browse   ·   Tab  light/dark   ·   Esc  cancel"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            text: "Enter to apply"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }
}
