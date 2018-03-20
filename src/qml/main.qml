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

    property Component nodeComponent: Component.Null //! Base component used to create nodes
    //    property var elements: [] //! Array containing all the nodes created
    property int count: 0

    width: 480
    height: 360
    visible: true

    // set unresizable
    maximumHeight: height
    maximumWidth: width
    minimumWidth: width
    minimumHeight: height

    title: qsTr("Neo")

    //    //Finish necessary initializations
    Component.onCompleted: {
        nodeComponent = Qt.createComponent("NeoNode.qml")
        menuBar.getMenu("file").insertItem(0, createMenu)
        console.log(menuBar.__menuBarComponent.height)
    }

    // exported in a file for readability
    menuBar: NeoMenuBar {
        id: menuBar
    }

    ScrollView {
        anchors.fill: parent
        Rectangle {
            id: mainArea
            width: 1000
            height: 1000
            property variant mouseEvent: null //! Used to store the last state of the mouse
            //    //! Main canvas of the program
            //    NeoCanvas {
            //        id: canvas
            //        nodes: elements
            //    }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                drag.target: parent

                signal rightClick
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                //! On press show menu and save mouse state
                onPressed: {
                    if (Qt.RightButton & pressedButtons) {
                        contextMenu.popup()
                        parent.mouseEvent = mouse
                    }
                }
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
                text: "Node"
                onTriggered: createNode()
            }
        }
    }

    //                onTriggered: createNode(
    //                                 ) // FIXME: Add parameters to method for special case where x, y is not defined, like from File menu
    //            }
    //        }
    //    }

    //    /*! \brief Create a new node.
    //        Use the previously loaded NeonodeComponent component to create new qml objects on demand
    //        TODO: Fails silently if the NeonodeComponent component wasn't successfully loaded
    //    */
    //    function createNode() {
    //        //        if (nodeComponent.status === Component.Ready) {

    //        // create node at click position
    //        var node = nodeComponent.createObject(app, {
    //                                                  x: mouseEvent.x,
    //                                                  y: mouseEvent.y
    //                                              })
    //        var node = Node.createObject()
    //        node.elements = elements
    //        node.name = String(count)
    //        node.canvas = canvas
    //        count += 1
    //        elements.push(node)
    //        canvas.baseCanvas.requestPaint()
    //        //        }
    //    }
    function createNode() {
        if (nodeComponent.status === Component.Ready) {
            var node = nodeComponent.createObject(mainArea, {
                                                      x: mainArea.mouseEvent.x,
                                                      y: mainArea.mouseEvent.y
                                                  })
            node.name = String(count)
            count += 1
        }
    }
}
