import QtQuick
import qs.theme

// The panel of the theme selector (also used alone to draw previews).
Item {
    id: root

    property int sel: 0
    property real shown: 1
    readonly property int cols: 5

    signal picked(int index)
    signal modeClicked(string mode)

    implicitWidth: card.width
    implicitHeight: card.height

    Rectangle {
        id: card

        width: root.cols * 150 + (root.cols - 1) * 12 + 40
        height: 64 + 2 * 124 + 12 + 28
        radius: 30
        color: Qt.rgba(Theme.island.r, Theme.island.g, Theme.island.b, 0.97)
        border.width: 1
        border.color: Theme.border
        opacity: root.shown
        scale: 0.94 + 0.06 * root.shown

        MouseArea { anchors.fill: parent }   // clicks inside do not close

        Text {
            x: 24; y: 22
            text: "Theme"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 14
            font.bold: true
        }

        // ---- Dark | Light ----
        Rectangle {
            id: seg
            anchors.horizontalCenter: parent.horizontalCenter
            y: 14
            width: 180; height: 32
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
                            onClicked: if (Appearance.mode !== parent.modelData.id) root.modeClicked(parent.modelData.id)
                        }
                    }
                }
            }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 24
            y: 24
            text: Appearance.applying ? "Repainting…" : "← ↑ ↓ →  ·  Tab light/dark  ·  Esc"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

        // ---- The themes ----
        Grid {
            x: 20; y: 64
            columns: root.cols
            spacing: 12

            Repeater {
                model: Appearance.themes

                delegate: Rectangle {
                    id: opt

                    required property var modelData
                    required property int index

                    readonly property var pv: Theme.preview(modelData.id)
                    readonly property bool chosen: root.sel === index
                    readonly property bool current: Appearance.theme === modelData.id

                    width: 150
                    height: 124
                    radius: 18
                    color: optMouse.containsMouse ? Theme.islandHover : Theme.surfaceSoft
                    border.width: chosen ? 2 : 1
                    border.color: chosen ? Theme.accent : Theme.border
                    Behavior on color { ColorAnimation { duration: 120 } }

                    // mini desktop painted with the colors of this theme
                    Rectangle {
                        x: 8; y: 8
                        width: parent.width - 16; height: 66
                        radius: 11
                        color: opt.pv.background
                        clip: true

                        Rectangle {   // pill
                            x: (parent.width - 62) / 2; y: 7
                            width: 62; height: 13; radius: 6.5
                            color: opt.pv.island
                            border.width: 1
                            border.color: opt.pv.border
                            Rectangle { x: 6; y: 4; width: 5; height: 5; radius: 2.5; color: opt.pv.foreground }
                            Rectangle { x: 15; y: 4.5; width: 18; height: 4; radius: 2; color: opt.pv.accent }
                            Rectangle { x: parent.width - 12; y: 4; width: 5; height: 5; radius: 2.5; color: opt.pv.note }
                        }
                        Rectangle {   // card
                            x: 10; y: 27
                            width: parent.width - 20; height: 32; radius: 8
                            color: opt.pv.island
                            border.width: 1
                            border.color: opt.pv.border
                            Rectangle { x: 8; y: 7; width: 40; height: 5; radius: 2.5; color: opt.pv.foreground }
                            Rectangle { x: 8; y: 16; width: 26; height: 4; radius: 2; color: opt.pv.muted }
                            Rectangle { x: 8; y: 24; width: 34; height: 4; radius: 2; color: opt.pv.accent }
                            Rectangle { x: parent.width - 22; y: 8; width: 12; height: 12; radius: 6; color: opt.pv.surfaceSoft }
                            Rectangle { x: parent.width - 20; y: 10; width: 8; height: 8; radius: 4; color: opt.pv.danger }
                        }
                    }

                    Text {
                        x: 12; y: 80
                        text: opt.modelData.name
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        x: 12; y: 98
                        width: parent.width - 24
                        text: opt.current ? "In use" : opt.modelData.hint
                        elide: Text.ElideRight
                        color: opt.current ? Theme.accent : Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: optMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.picked(opt.index)
                    }
                }
            }
        }
    }

}
