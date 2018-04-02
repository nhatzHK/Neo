import QtQuick 2.0

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

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        preventStealing: true
        onClicked: {
            if (Qt.LeftButton & acceptedButtons) {
                console.log("Overriding")
            }
        }
    }
}
