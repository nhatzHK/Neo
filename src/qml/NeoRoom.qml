import QtQuick 2.0
import QtQuick.Controls 1.4
import Neo.Room 1.0
import Neo.Node 1.0
import Neo.Connection 1.0

Rectangle {
    id: room
    color: "red"
    anchors.fill: parent

    Component.onCompleted: {
        //        connectionComponent = Qt.createComponent("NeoConnection.qml")
        nodeComponent = Qt.createComponent("NeoInput.qml")
        gateComponent = Qt.createComponent("NeoGate.qml")
        outputComponent = Qt.createComponent("NeoOutput.qml")
    }

    property int nodeCount: 0
    property int gateCount: 0
    property int outputCount: 0
    property Room backend: Room {
        onNodeDeleted: console.log(nodes.length)
    }

    property variant mouseEvent: null //! Used to store the last state of the mouse
    property alias createNodeMenu: createNodeMenu

    property Component nodeComponent: Component.Null
    //    property Component connectionComponent: Component.Null
    property Component gateComponent: Component.Null
    property Component outputComponent: Component.Null

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
                        if (inputPopup.visible)
                            inputPopup.hideCard()
                        if (gatePopup.visible)
                            gatePopup.hideCard()
                        if (outputPopup.visible)
                            outputPopup.hideCard()
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
            title: qsTr("Create Node")

            MenuItem {
                text: "Input"
                onTriggered: createInput()
            }

            MenuItem {
                text: "Output"
                onTriggered: createOutput()
            }
        }

        Menu {
            id: createGateMenu
            title: qsTr("Create Gate")

            MenuItem {
                text: qsTr("Or")
                onTriggered: createGate(Node.OrGate)
            }

            MenuItem {
                text: qsTr("And")
                onTriggered: createGate(Node.AndGate)
            }
        }
    }

    NeoCardInput {
        id: inputPopup
        x: room.width * 1 / 6
        y: room.height * 1 / 6
        width: room.width * 4 / 6
        height: room.height * 4 / 6
    }

    NeoCardGate {
        id: gatePopup
        x: room.width * 1 / 6
        y: room.height * 1 / 6
        width: room.width * 4 / 6
        height: room.height * 4 / 6
    }

    NeoCardOutput {
        id: outputPopup
        x: room.width * 1 / 6
        y: room.height * 1 / 6
        width: room.width * 4 / 6
        height: room.height * 4 / 6
    }

    function createInput() {
        if (nodeComponent.status === Component.Ready) {
            var x = mouseEvent === null ? room.width / 2 : mouseEvent.x
            var y = mouseEvent === null ? room.height / 2 : mouseEvent.y
            var node = nodeComponent.createObject(mainArea, {
                                                      x: x,
                                                      y: y,
                                                      room: room
                                                  })
            node.name = "node" + String(nodeCount)
            ++nodeCount
            backend.nodes.push(node.backend)
            node.forget.connect(popNode)
            node.showCard.connect(showCard)
            node.backend.type = Node.Input
        } else {
            console.log("Input not ready")
        }
    }

    function createGate(type) {
        if (gateComponent.status === Component.Ready) {
            var x = mouseEvent === null ? room.width / 2 : mouseEvent.x
            var y = mouseEvent === null ? room.height / 2 : mouseEvent.y

            var gate = gateComponent.createObject(mainArea, {
                                                      x: x,
                                                      y: y,
                                                      room: room
                                                  })

            gate.name = "gate" + String(gateCount)
            ++gateCount
            backend.nodes.push(gate.backend)
            gate.forget.connect(popNode)
            gate.showCard.connect(showCard)
            gate.backend.type = type
        } else {
            console.log("Gate not ready")
        }
    }

    function createOutput() {
        if (outputComponent.status === Component.Ready) {
            var x = mouseEvent === null ? room.width / 2 : mouseEvent.x
            var y = mouseEvent === null ? room.height / 2 : mouseEvent.y

            var output = outputComponent.createObject(mainArea, {
                                                          x: x,
                                                          y: y,
                                                          room: room
                                                      })

            output.name = "output" + String(outputCount)
            ++outputCount
            backend.nodes.push(output.backend)
            output.forget.connect(popNode)
            output.showCard.connect(showCard)
            output.backend.type = Node.Output
        } else {
            console.log("Output not ready")
        }
    }

    function showCard(n) {
        switch (n.type) {
        case Node.Input:
            gatePopup.hideCard()
            outputPopup.hideCard()
            inputPopup.showCard(n, room.backend)
            break
        case Node.OrGate:
        case Node.AndGate:
            inputPopup.hideCard()
            outputPopup.hideCard()
            gatePopup.showCard(n, room.backend)
            break
        case Node.Output:
            inputPopup.hideCard()
            gatePopup.hideCard()
            outputPopup.showCard(n, room.backend)
            break
        }
    }

    function popNode(n) {
        backend.deleteNode(n)
        for (var i = 0; i < backend.nodes.length; ++i) {
            backend.nodes[i].connectionsHaveChanged()
        }
        paint()
    }

    function paint() {
        canvas.requestPaint()
    }
}
