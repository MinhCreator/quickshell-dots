import QtQuick
import qs.theme
import qs.widgets

Item {
    id: root

    property string title: ""
    property bool showSwitch: false
    property bool checked: false
    signal back()
    signal toggled()

    implicitHeight: 28

    NavButton {
        label: "‹"
        onClicked: root.back()
    }

    Text {
        x: 38
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.bold: true
    }

    Toggle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.showSwitch
        checked: root.checked
        onToggled: root.toggled()
    }
}
