import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4


/*! \brief Main window of the program.
        This is the outmost layer.
        Every other component is a (direct or indirect child) of this.
*/
ApplicationWindow {
    id: app

    property Component basicNode: Component.Null //! Base component used to create nodes
    property var elements: [] //! Array containing all the nodes created
    property variant mouseEvent: null //! Used to store the last state of the mouse
    property int count: 0

    width: 480
    height: 360
    visible: true

    // set unresizable
    maximumHeight: height
    maximumWidth: width
    minimumWidth: width
    minimumHeight: height

    // exported in

    // exported in

    title: qsTr("Neo")

    //Finish necessary initializations
    Component.onCompleted: {
        basicNode = Qt.createComponent("NeoBasicNode.qml")
        menuBar.getMenu("file").insertItem(0, createMenu)
    }

    // exported in a file for readability
    menuBar: NeoMenuBar {
        id: menuBar
    }

    //! Main canvas of the program
    NeoCanvas {
        id: canvas
        nodes: elements
    }

    MouseArea {
        id: mouseArea
        x: 0
        y: 0
        anchors.fill: parent
        drag.target: parent

        signal rightClick
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        //! On press show menu and save mouse state
        onPressed: {
            if (Qt.RightButton & pressedButtons) {
                contextMenu.popup()
                mouseEvent = mouse
            }
        }
    }

    //! Context menu accessible by clicking directly on the canvas
    Menu {
        id: contextMenu

        title: qsTr("Canvas Menu")

        Menu {
            id: createMenu
            title: qsTr("Create")

            MenuItem {
                text: "NeoBasicNode"
                onTriggered: createBasicNode()
            }
        }
    }

    /*! \brief Create a new node.
        Use the previously loaded NeoBasicNode component to create new qml objects on demand
        TODO: Fails silently if the NeoBasicNode component wasn't successfully loaded
    */
    function createBasicNode() {
        if (basicNode.status === Component.Ready) {

            // create node at click position
            var node = basicNode.createObject(app, {
                                                  x: mouseEvent.x,
                                                  y: mouseEvent.y
                                              })
            node.elements = elements
            node.name = String(count)
            node.canvas = canvas
            count += 1
            elements.push(node)
            canvas.baseCanvas.requestPaint()
        }
    }
}
