import QtQuick 2.10
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

    onCurrentNodeChanged: {
        nameTag.displayText = currentNode.name
    }

    Column {
        anchors.fill: parent
        NeoLabelField {
            id: nameTag
            width: popup.width
            height: popup.height / 10
            displayColor: currentNode.output ? "green" : "red"
            editColor: "#2979ff"
            onTextChanged: currentNode.name = displayText
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
                            if (currentNode === modelData
                                    || modelData.type === Node.Output) {
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
                            if (currentNode === modelData
                                    || modelData.type === Node.Inputn) {
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
