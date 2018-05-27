import QtQuick 2.0
import QtQuick.Controls 1.4
import Neo.Node 1.0

Rectangle {
    id: node

    width: 100
    height: 100
    radius: height
    color: "#566c73"
    border.width: 5
    border.color: backend.output ? "green" : "red"

    signal forget(Node g)
    signal showCard(Node g)

    property Component dynamicMenuItem: null
    property NeoRoom room: NeoRoom {
    }
    property alias name: backend.name
    property alias backend: backend

    property Item inSlot: NeoRadioButton {
        y: node.height / 2
        x: -4
        visible: false
        parent: node
    }

    Component.onCompleted: {
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
        room.backend.evaluate(backend)
    }

    Node {
        id: backend
        type: Node.Output
        onConnectionsHaveChanged: {
            inSlot.visible = room.backend.hasInConnection(backend)
            room.backend.evaluate(backend)
        }
        inPos: Qt.point(node.x + inSlot.x, node.y + inSlot.y + 4)
        pos: Qt.point(node.x, node.y)
    }

    Text {
        id: nameTag
        color: "white"
        text: backend.name

        font.bold: true
        font.pointSize: 14
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    onXChanged: {
        room.paint()
    }

    onYChanged: {
        room.paint()
    }

    MouseArea {
        id: drag_area
        anchors.fill: parent
        drag.target: node
        propagateComposedEvents: true
        signal rightClick
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        // show context menu on leftclick pressed over the gate
        onPressed: {
            if (Qt.RightButton & pressedButtons) {
                contextMenu.popup()
            }
        }

        onClicked: {
            if (!mouse.wasHeld) {
                showCard(backend)
            }
        }
    }

    // ! Context menu
    Menu {
        id: contextMenu
        title: qsTr("Gate menu")

        Menu {
            title: qsTr("Connect To")
            Menu {
                id: menuConnectNode
                title: qsTr("Nodes")
                onAboutToShow: {
                    menuConnectNode.clear()
                    makeNodeList(menuConnectNode)
                }
            }

            Menu {
                id: menuConnectGate
                title: qsTr("Gates")
                onAboutToShow: {
                    menuConnectGate.clear()
                    makeGateList(menuConnectGate, Node.OrGate)
                    makeGateList(menuConnectGate, Node.AndGate)
                }
            }
        }

        MenuItem {
            text: qsTr("Delete")
            onTriggered: {
                node.forget(backend)
                node.destroy()
            }
        }
    }

    function makeGateList(menu, type) {
        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (nodes[i].type === type) {
                console.log(nodes[i])
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend, nodes[i],
                                                             Node.Output)

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend, nodes[i],
                                                          Node.Output)
                        } else {
                            room.backend.removeConnections(backend, nodes[i],
                                                           Node.Output)
                        }

                        backend.connectionsHaveChanged()
                        nodes[i].connectionsHaveChanged()
                        room.paint()
                    })
                }
            }
            rec_for(nodes, i + 1)
        }

        rec_for(room.backend.nodes, 0)
    }

    function makeNodeList(menu) {
        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (nodes[i] !== node.backend && nodes[i].type === Node.Input) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend, nodes[i],
                                                             Node.Output)

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend, nodes[i],
                                                          Node.Output)
                        } else {
                            room.backend.removeConnections(backend, nodes[i],
                                                           Node.Output)
                        }

                        backend.connectionsHaveChanged()
                        nodes[i].connectionsHaveChanged()
                        room.paint()
                    })
                }
            }
            rec_for(nodes, i + 1)
        }

        rec_for(room.backend.nodes, 0)
    }
}
