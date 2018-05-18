import QtQuick 2.6
import QtQuick.Controls 2.1
import Neo.Node 1.0

CheckBox {
    id: control

    property string enabledText: "On"
    property string disabledText: "Off"
    property color enabledColor: "green"
    property color color: "grey"
    property real toggleOverlap: 10

    onCheckedChanged: {
        animateToggle.start()
    }

    indicator: Rectangle {
        anchors.fill: parent

        Row {
            anchors.fill: parent
            Text {
                height: parent.height
                width: parent.width / 4

                text: disabledText
                font.bold: true
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                width: parent.width / 4 * 2
                height: parent.height
                radius: height / 2

                Rectangle {
                    width: parent.width - toggleOverlap
                    height: parent.height - toggleOverlap
                    anchors.centerIn: parent
                    radius: height / 2
                    color: control.color

                    Rectangle {
                        height: parent.height
                        width: handle.x + handle.width / 2
                        radius: height / 2

                        color: enabledColor
                    }
                }

                Rectangle {
                    id: handle
                    width: parent.height
                    height: width
                    radius: height / 2

                    color: control.checked ? Qt.darker(
                                                 enabledColor) : Qt.darker(
                                                 control.color)
                    SmoothedAnimation {
                        id: animateToggle
                        property real begin: handle.x
                        property real end: control.checked ? 0.0 : handle.parent.width - handle.width
                        target: handle
                        properties: "x"
                        from: begin
                        to: end
                    }
                }
            }

            Text {
                width: parent.width / 4
                height: parent.height

                text: enabledText
                font.bold: true
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    function updateHandlePosition() {
        animateToggle.stop()
        handle.x = control.checked ? handle.parent.width - handle.width : 0.0
    }
}
