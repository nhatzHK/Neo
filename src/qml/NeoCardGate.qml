import QtQuick 2.0
import QtQuick.Controls 2.3
import Neo.Room 1.0
import Neo.Node 1.0

Item {
    id: popup
    focus: true
    visible: false

    property Node currentNode: dummyNode
    Node {
        id: dummyNode
    }

    property Room currentRoom: dummyRoom
    Room {
        id: dummyRoom
    }

    Column {
        anchors.fill: parent
        Rectangle {
            width: popup.width
            height: popup.height / 10
            color: currentNode.type === Node.Input ? "blue" : "red"
            Text {
                id: nameTag
                anchors.fill: parent
                color: "white"
                text: currentNode.name
                font.bold: true
                font.pointSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                }
            }
        }

        Rectangle {
            id: comRect
            width: popup.width
            height: popup.height / 10 * 9

            Column {
                anchors.fill: parent
                NeoComboBox {
                    id: inCom
                    width: parent.width
                    height: parent.height / 2
                    model: currentRoom.nodes
                    name: "Incoming connections"
                    delegate: CheckBox {
                        checkState: {
                            if (currentNode === modelData || modelData.type === Node.Output) {
                                enabled = false
                            }

                            if (currentRoom.connected(currentNode, modelData,
                                                      Node.Output)) {
                                return Qt.Checked
                            } else {
                                return Qt.Unchecked
                            }
                        }

                        onClicked: {
                            if (checked) {
                                currentRoom.createConnection(currentNode,
                                                             modelData,
                                                             Node.Output)
                            } else {
                                currentRoom.removeConnections(currentNode,
                                                              modelData,
                                                              Node.Output)
                            }

                            currentNode.connectionsHaveChanged()
                            modelData.connectionsHaveChanged()
                            currentRoom.paint()
                        }

                        text: modelData.name
                        font.bold: true
                        font.pointSize: 14
                    }
                }

                NeoComboBox {
                    id: outCom
                    width: parent.width
                    height: parent.height / 2
                    model: currentRoom.nodes
                    name: "Outgoing Connections"
                    delegate: CheckBox {
                        checkState: {
                            if (currentNode === modelData || modelData.type === Node.Inputn) {
                                enabled = false
                            }

                            if (currentRoom.connected(currentNode, modelData,
                                                      Node.Input)) {
                                return Qt.Checked
                            } else {
                                return Qt.Unchecked
                            }
                        }

                        onClicked: {
                            if (checked) {
                                currentRoom.createConnection(currentNode,
                                                             modelData,
                                                             Node.Input)
                            } else {
                                currentRoom.removeConnections(currentNode,
                                                              modelData,
                                                              Node.Input)
                            }

                            currentNode.connectionsHaveChanged()
                            modelData.connectionsHaveChanged()
                            currentRoom.paint()
                        }

                        text: modelData.name
                        font.bold: true
                        font.pointSize: 14
                    }
                }
            }
        }
    }

    function showCard(node, room) {
        currentNode = node
        currentRoom = room
        visible = true
    }

    function hideCard() {
        currentNode = dummyNode
        currentRoom = dummyRoom
        visible = false
    }
}
