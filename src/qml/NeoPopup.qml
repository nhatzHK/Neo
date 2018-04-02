import QtQuick 2.0
import Neo.Node 1.0

Item {
    id: popup
    focus: true
    visible: true

    //    width: 100
    //    height: 100
    Component.onCompleted: {
        visible = false
    }

    property Node currentNode: dummyNode
    Node {
        id: dummyNode
    }

    Column {
        anchors.fill: parent
        Rectangle {
            width: popup.width
            height: popup.height / 10
            color: "blue"
            Text {
                anchors.fill: parent
                id: nameTag
                color: "white"
                text: currentNode.name
                font.bold: true
                font.pointSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: mainArea
            width: popup.width
            height: popup.height / 10 * 4
            color: "lightblue"
            Row {
                anchors.fill: parent
                Text {
//                    anchors.fill: parent
                    id: data
                    height: parent.height
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 20
                    text: String(currentNode.value)
                    color: "black"
                    font.bold: true
                }

                Rectangle {
                    id: overrideButton
                    color: "red"
                    height: parent.height
                    width: parent.width / 2
                    border.width: 5
                    border.color: "purple"
                    radius: 100
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Override")
                        color: "rosybrown"
                        font.bold: true
                        font.pointSize: 30
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Rectangle {
            id: idkman
            color: "red"
            width: parent.width
            height: parent.height / 10 * 5
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    function showCard(node) {
        currentNode = node
        visible = true
    }

    function hideCard() {
        currentNode = dummyNode
        visible = false
    }
}
