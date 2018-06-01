import QtQuick 2.10
import QtQuick.Controls 2.3

MenuBar {
    id: menuBar
    property color color: "#2979ff"


    signal clear
    signal load
    signal save
    signal saveAs
    signal quit

    NeoMenu {
        id: fileMenu

        title: qsTr("File")

        NeoMenuItem {
            text: qsTr("Open room ...")
            onTriggered: load()
        }

        NeoMenuSeparator{}

        NeoMenuItem {
            text: qsTr("Save")
            onTriggered: save()
        }

        NeoMenuItem {
            text: qsTr("Save as...")
            onTriggered: saveAs()
        }

        NeoMenuSeparator {}

        NeoMenuItem {
            text: qsTr("Clear room")
            onTriggered: clear()
        }

        NeoMenuSeparator{}

        NeoMenuItem {
            text: qsTr("Exit")
            onTriggered: quit()
        }
    }

    delegate: MenuBarItem {
        id: menuBarItem

        contentItem: Text {
            text: menuBarItem.text
            color: menuBarItem.highlighted ? "#ffffff" : menuBar.color
        }

        background: Rectangle {
            opacity: enabled ? 1 : 0.3
            color: menuBarItem.highlighted ? menuBar.color : "transparent"
        }
    }

    background: Rectangle {
        color: "#ffffff"

        Rectangle {
            color: menuBar.color
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
        }
    }
}
