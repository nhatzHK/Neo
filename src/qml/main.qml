import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Neo.Node 1.0


/*! \brief Main window of the program.
        This is the outmost layer.
        Every other component is a (direct or indirect child) of this.
*/
ApplicationWindow {
    id: app

    //    property var elements: [] //! Array containing all the nodes created
    //    property int count: 0
    width: 480
    height: 360
    visible: true

    // set unresizable
    maximumHeight: height
    maximumWidth: width
    minimumWidth: width
    minimumHeight: height

    title: qsTr("Neo")

    //Finish necessary initializations
    Component.onCompleted: {
        menuBar.getMenu("file").insertItem(0, room.createNodeMenu)
        app.menuBar = mnuBar
    }

    // exported in a file for readability
    menuBar: NeoMenuBar {
        id: mnuBar
    }

    NeoRoom {
        id: room
    }
}
