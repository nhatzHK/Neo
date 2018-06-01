import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4
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
        openedSwitch.checked = currentNode.opened
        invertedSwitch.checked = currentNode.inverted

        openedSwitch.updateHandlePosition()
        invertedSwitch.updateHandlePosition()
    }

    Column {
        anchors.fill: parent
        Rectangle {
            width: parent.width
            height: parent.height / 10
            color: currentNode.output ? "green" : "red"
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
            width: parent.width
            height: parent.height / 10 * 7

            Row {
                anchors.fill: parent
                Column {
                    width: parent.width / 2
                    height: parent.height
                    Text {
                        id: data
                        height: parent.height / 2
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 40
                        text: currentNode.value.toFixed(2)
                        color: "black"
                        font.bold: true

                        MouseArea {
                            anchors.fill: parent
                        }
                    }

                    Label {
                        id: addressLabel
                        width: parent.width
                        height: parent.height / 4
                        text: qsTr("OSC Address")
                        font.pointSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        background: Rectangle {
                            color: "blue"
                        }
                    }

                    TextField {
                        id: addressInput
                        width: parent.width
                        height: parent.height / 4
                        placeholderText: qsTr("Enter OSC address here")
                        text: currentNode.address
                        onEditingFinished: currentNode.address = text
                    }
                }

                Column {
                    height: parent.height
                    width: parent.width / 2
                    NeoRangeSlider {
                        width: parent.width
                        height: parent.height / 2
                        id: rangeSlider
                        currentNode: popup.currentNode
                    }

                    NeoSwitch {
                        id: invertedSwitch
                        width: parent.width
                        height: parent.height / 4
                        enabledText: "Inverted"
                        disabledText: "Normal"
                        enabledColor: "blue"
                        color: "#566c73"
                        onClicked: {
                            currentNode.inverted = checked
                            currentNode.connectionsHaveChanged()
                        }
                    }

                    NeoSwitch {
                        id: openedSwitch
                        width: parent.width
                        height: parent.height / 4
                        enabledText: "On"
                        disabledText: "Off"
                        enabledColor: "blue"
                        color: "#566c73"
                        onClicked: {
                            currentNode.opened = checked
                            currentNode.connectionsHaveChanged()
                        }
                    }
                }
            }
        }

        Rectangle {
            id: comRect
            width: parent.width
            height: parent.height / 10 * 2

            Column {
                anchors.fill: parent
                NeoComboBox {
                    id: outCom
                    width: parent.width
                    height: parent.height
                    model: currentRoom.nodes
                    name: "Connections"
                    delegate: CheckBox {
                        checkState: {
                            if (currentNode === modelData
                                    || modelData.type === Node.Input) {
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
