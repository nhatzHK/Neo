import QtQuick 2.0
import QtQuick.Controls 1.4

MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit()
            }
        }
}
