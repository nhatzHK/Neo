import QtQuick 2.0
import QtQuick.Controls 1.4
import Neo.Room 1.0
import Neo.Node.Input 1.0

Rectangle {
    id: room
    color: "red"
    anchors.fill: parent

    Component.onCompleted: {
        connectionComponent = Qt.createComponent("NeoConnection.qml")
        nodeComponent = Qt.createComponent("NeoInputNode.qml")
    }

    property int count: 0
    property Room backend: Room {
        onNodeDeleted: console.log(nodes.length)
    }

    property variant mouseEvent: null //! Used to store the last state of the mouse
    property alias createNodeMenu: createNodeMenu

    property Component nodeComponent: Component.Null
    property Component connectionComponent: Component.Null

    ScrollView {
        anchors.fill: parent
        Rectangle {
            id: mainArea
            width: 1500
            height: 1500

            NeoCanvas {
                id: canvas
                room: backend
                anchors.fill: parent
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                signal rightClick
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                //! On press show menu and save mouse state
                onPressed: {
                    if (Qt.RightButton & pressedButtons) {
                        contextMenu.popup()
                        room.mouseEvent = mouse
                    } else if (Qt.LeftButton & pressedButtons) {
                        popup.hideCard()
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
            id: createNodeMenu
            title: qsTr("Create Node Menu")

            MenuItem {
                text: "Node"
                onTriggered: createNode()
            }
        }
    }

    NeoPopup {
        id: popup
        x: room.width * 1 / 6
        y: room.height * 1 / 6
        width: room.width * 4 / 6
        height: room.height * 4 / 6
    }

    function createNode() {
        if (nodeComponent.status === Component.Ready) {
            var x = mouseEvent === null ? room.width / 2 : mouseEvent.x
            var y = mouseEvent === null ? room.height / 2 : mouseEvent.y
            var node = nodeComponent.createObject(mainArea, {
                                                      x: x,
                                                      y: y,
                                                      room: room
                                                  })
            node.name = "node" + String(count)
            ++count
            backend.nodes.push(node.backend)
            node.forget.connect(popNode)
            node.showCard.connect(showCard)
        } else {
            console.log("Node not Ready")
        }
    }

    function showCard(n) {
        popup.showCard(n, room.backend)
    }

    function popNode(n) {
        backend.deleteNode(n)
        for (var i = 0; i < backend.nodes.length; ++i) {
            backend.nodes[i].connectionsMightHaveChanged()
        }
    }

    function paint() {
        canvas.requestPaint()
    }
}
