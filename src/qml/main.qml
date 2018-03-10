import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

ApplicationWindow {
    width: 640
    height: 480
    visible: true

    // set unresizable
    maximumHeight: height
    maximumWidth: width
    minimumWidth: width
    minimumHeight: height

    title: qsTr("Neo")

    menuBar: NeoMenuBar {
    }
    NeoCanvas {
        id: canvas
    }

    NeoBasicNode {
        id: node1
        canvas: canvas
        Component.onCompleted: {
            addIO("in")
            addIO("out")
        }
    }
}
