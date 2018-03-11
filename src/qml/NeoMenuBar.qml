import QtQuick 2.0
import QtQuick.Controls 1.4

MenuBar {

    Menu {
        id: fileMenu
        title: qsTr("File")
        MenuItem {
            text: qsTr("Exit")
            onTriggered: Qt.quit()
        }
    }

    function getMenu(menu) {
        switch (menu) {
        case "file":
            return fileMenu
        default:
            console.warn("[NeoMenuBar] Menu " + menu + " not found.")
        }
    }
}
