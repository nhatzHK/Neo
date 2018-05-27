import QtQuick 2.9
import QtQuick.Controls 1.4

MenuBar {

    signal clear
    signal load
    signal save
    Menu {
        id: fileMenu
        title: qsTr("File")

        MenuItem {
            text: qsTr("Clear room")
            onTriggered: clear()
        }

        MenuItem {
            text: qsTr("Save")
            onTriggered: save()
        }

        MenuItem {
            text: qsTr("Load room")
            onTriggered: load()
        }

        MenuItem {
            text: qsTr("Exit")
            onTriggered: Qt.quit()
        }
    }

    /*! Return a menu from the bar
        FIXME: HARDCODED
        \param menu Lowercase name of the menu to return
    */
    function getMenu(menu) {
        switch (menu) {
        case "file":
            return fileMenu
        default:
            console.warn("[NeoMenuBar] Menu " + menu + " not found.")
        }
    }
}
