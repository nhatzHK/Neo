import QtQuick 2.0

Rectangle {
    id: overrideButton
    color: "red"
    height: 20
    width: height
    border.width: 5
    border.color: "purple"
    radius: width/2
    signal clicked
    Text {
        anchors.centerIn: parent
        text: qsTr("Override")
        color: "rosybrown"
        font.bold: true
        font.pointSize: 18
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
                overrideButton.clicked()
            }
        }
    }
}
