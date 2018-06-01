import QtQuick 2.10
import QtQuick.Controls 2.3

ComboBox {
    id: control
    width: 20
    height: 10

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
        font.pointSize: 14
        text: name
    }

    property string name: "Combo Box"
}
