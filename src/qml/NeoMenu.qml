import QtQuick 2.10
import QtQuick.Controls 2.3

Menu {
    id: menu
    property color color: "#2979ff"

    delegate: NeoMenuItem {
        color: menu.color
    }

    background: Rectangle {
        anchors.fill: parent
        implicitWidth: 100
        color: "#ffffff"
        border.color: menu.color
        radius: 2
    }
}
