import QtQuick 2.0
import QtQuick.Controls 1.4
import Neo.Room 1.0
import Neo.Node 1.0
import Neo.Connection 1.0

Rectangle {
    id: room
    color: "transparent"
    anchors.fill: parent

    signal clearAll

    signal loadNodes
    Component.onCompleted: {
        nodeComponent = Qt.createComponent("NeoInput.qml")
        gateComponent = Qt.createComponent("NeoGate.qml")
        outputComponent = Qt.createComponent("NeoOutput.qml")
    }

    property int nodeCount: 0
    property int gateCount: 0
    property int outputCount: 0
    //    property var createdNodes: []
    property Room backend: Room {
        onRoomLoaded: {
            loadVisualNodes()
        }
    }

    property variant mouseEvent: null //! Used to store the last state of the mouse
    property alias createNodeMenu: createNodeMenu

    property Component nodeComponent: Component.Null
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

    function createInput(fromJson) {

        if (nodeComponent.status === Component.Ready) {
            var x = mouseEvent === null ? room.width / 2 : mouseEvent.x
            var y = mouseEvent === null ? room.height / 2 : mouseEvent.y
            var node = nodeComponent.createObject(mainArea, {
                                                      room: room
                                                  })

            if (fromJson === undefined || !fromJson) {
                node.backend.name = "input" + String(nodeCount)
                room.backend.nodes.push(node.backend)
                node.backend.type = Node.Input
                node.x = x
                node.y = y
            } else {
                room.backend.loadNextNode(node.backend)
                node.setPosition(node.backend.pos.x, node.backend.pos.y)
            }

            ++nodeCount
            node.forget.connect(popNode)
            room.clearAll.connect(node.forgetAll)
            node.showCard.connect(showCard)
        } else {
            console.log("Input not ready")
        }
    }

    function createGate(type, fromJson) {
        if (gateComponent.status === Component.Ready) {
            var x = mouseEvent === null ? room.width / 2 : mouseEvent.x
            var y = mouseEvent === null ? room.height / 2 : mouseEvent.y

            var gate = gateComponent.createObject(mainArea, {
                                                      room: room
                                                  })

            if (fromJson === undefined || !fromJson) {
                gate.backend.name = "gate" + String(gateCount)
                room.backend.nodes.push(gate.backend)
                gate.backend.type = type
                gate.x = x
                gate.y = y
            } else {
                room.backend.loadNextNode(gate.backend)
                gate.setPosition(gate.backend.pos.x, gate.backend.pos.y)
            }

            ++gateCount
            gate.forget.connect(popNode)
            room.clearAll.connect(gate.forgetAll)
            gate.showCard.connect(showCard)
            gate.name = gate.backend.name
        } else {
            console.log("Gate not ready")
        }
    }

    function createOutput(fromJson) {
        if (outputComponent.status === Component.Ready) {
            var x = mouseEvent === null ? room.width / 2 : mouseEvent.x
            var y = mouseEvent === null ? room.height / 2 : mouseEvent.y

            var output = outputComponent.createObject(mainArea, {
                                                          room: room
                                                      })

            if (fromJson === undefined || !fromJson) {
                output.backend.name = "output" + String(outputCount)
                room.backend.nodes.push(output.backend)
                output.backend.type = Node.Output
                output.x = x
                output.y = y
            } else {
                room.backend.loadNextNode(output.backend)
                output.setPosition(output.backend.pos.x, output.backend.pos.y)
            }

            ++outputCount
            output.forget.connect(popNode)
            room.clearAll.connect(output.forgetAll)
            output.showCard.connect(showCard)
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

    function loadVisualNodes() {
        while (backend.hasMoreLoaded()) {
            switch (backend.nextType()) {
            case Node.Input:
                createInput(true)
                break
            case Node.Output:
                createOutput(true)
                break
            case Node.OrGate:
            case Node.AndGate:
                createGate(backend.nextType(), true)
                break
            }
        }
        backend.loadConnections()
    }
}
