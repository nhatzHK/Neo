import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle {
    id: labelField
    property string displayText: "Text"

    property color displayColor: "green"
    property color editColor: "red"

    signal textChanged()

    width: 50
    height: 50

    color: {
        if (field.focus) {
            return editColor
        } else {
            return displayColor
        }
    }

    Text {
        anchors.fill: parent
        id: tag
        color: "white"
        text: displayText
        font.bold: true
        font.pointSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    TextField {
        id: field
        anchors.fill: parent
        opacity: 0
        anchors.centerIn: parent
        text: labelField.displayText
        onTextChanged: labelField.displayText = text
        onEditingFinished: {
            focus = false
            labelField.textChanged()
        }
    }
}
