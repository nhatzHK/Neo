import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

/*! \brief Main window of the program.
        This is the outmost layer.
        Every other component is a (direct or indirect child) of this.
*/
ApplicationWindow {
    id: app

    width: 480
    height: 360
    visible: true

    // set unresizable
    maximumHeight: height
    maximumWidth: width
    minimumWidth: width
    minimumHeight: height

    title: qsTr("Neo")

    // Finish necessary initializations
    Component.onCompleted: {
        menuBar.getMenu("file").insertItem(0, room.createNodeMenu)
        app.menuBar = mnuBar
    }

    menuBar: NeoMenuBar {
        id: mnuBar

        onClear: {
            room.clearAll()
        }

        onLoad: {
            room.loadNodes()
        }

        onSave: {
            room.backend.save()
        }
    }

    NeoRoom {
        id: room

        Component.onCompleted: {
            backend.initSocket()
        }
    }
}
