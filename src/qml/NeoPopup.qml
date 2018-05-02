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
            id: mainArea
            width: popup.width
            height: popup.height / 10 * 4

            Row {
                anchors.fill: parent
                Text {
                    id: data
                    height: parent.height
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 20
                    text: String(currentNode.value)
                    color: "black"
                    font.bold: true

                    MouseArea {
                        anchors.fill: parent
                    }
                }

                NeoOverrideButton {
                    id: overrideButton
                    width: parent.width / 2
                    height: parent.height
                    onClicked: {
                        console.log("Overriding")
                    }
                }
            }
        }

        Rectangle {
            id: comRect
            width: popup.width
            height: popup.height / 10 * 3

            Column {
                anchors.fill: parent
                NeoComboBox {
                    id: inCom
                    width: parent.width
                    height: popup.height / 10
                    model: currentRoom.nodes
                    name: "Incoming connections"
                    delegate: CheckBox {
                        checkState: {
                            if (currentNode === modelData) {
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
                            currentNode.rowId = modelData
                        }

                        text: modelData.name
                        font.bold: true
                        font.pointSize: 14
                    }
                }

                NeoComboBox {
                    id: outCom
                    width: parent.width
                    height: popup.height / 10
                    model: currentRoom.nodes
                    name: "Outgoing Connections"
                    delegate: CheckBox {
                        checkState: {
                            if (currentNode === modelData) {
                                enabled = false
                            }

                            if (currentRoom.connected(currentNode, modelData,
                                                      Node.Output)) {
                                return Qt.Checked
                            } else {
                                return Qt.Unchecked
                            }
                        }
                        text: modelData.name
                        font.bold: true
                        font.pointSize: 14
                    }
                }

                NeoComboBox {
                    id: componentList
                    width: parent.width
                    height: popup.height / 10
                    model: currentRoom.ids
                    name: "Component List"
                    ButtonGroup{
                        buttons: componentList.delegate
                        exclusive: true
                    }

                    delegate: RadioButton {
                        checked: currentNode.rowId === modelData

                        onCheckedChanged: {
                            if(checked) {
                                currentNode.rowId = modelData
                            }
                        }

                        text: modelData
                    }
                }
            }
        }

        Rectangle {
            width: popup.width
            height: popup.height / 10 * 2
            color: "green"

            MouseArea {
                anchors.fill: parent
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
