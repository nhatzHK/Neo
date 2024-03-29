import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.2

/*! \brief Main window of the program.
        This is the outmost layer.
        Every other component is a (direct or indirect child) of this.
*/
ApplicationWindow {
    id: app

    width: 480
    height: 360
    visible: true

    // set unresizable
    maximumHeight: height
    maximumWidth: width
    minimumWidth: width
    minimumHeight: height

    title: qsTr("Neo")

    menuBar: NeoMenuBar {

        onClear: {
            if (room.backend.changesSaved()) {
                confirmDialog.confirmAndProceed(
                            room.clearAll, qsTr("Clear"), qsTr(
                                "Clearing the room will discard your changes.\nContinue without saving?"))
            } else {
                room.clearAll()
            }
        }

        onLoad: {
            if (!room.backend.changesSaved()) {
                confirmDialog.confirmAndProceed(function () {
                    fileDialog.state = "loading"
                    fileDialog.open()
                }, qsTr("Clear"), qsTr(
                    "Loading a new room will discard your changes.\nContinue without saving?"))
            } else {
                fileDialog.state = "loading"
                fileDialog.open()
            }
        }

        onSave: {
            if (room.backend.savedBefore()) {
                room.backend.save()
            } else {
                saveAs()
            }
        }

        onSaveAs: {
            fileDialog.state = "saving"
            fileDialog.open()
        }

        onQuit: {
            if (!room.backend.changesSaved()) {
                confirmDialog.confirmAndProceed(
                            Qt.quit, qsTr("Quit"), qsTr(
                                "Your changes aren't saved.\nQuit without saving?"))
            } else {
                Qt.quit()
            }
        }
    }

    onClosing: {
        close.accepted = false
        if (!room.backend.changesSaved()) {
            confirmDialog.confirmAndProceed(function () {
                Qt.quit()
            }, qsTr("Quit"),
            qsTr("Your changes aren't saved.\nQuit without saving?"))
        } else {
            Qt.quit()
        }
    }

    NeoRoom {
        width: 500
        height: 500
        id: room

        Component.onCompleted: {
            backend.initSocket()
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home
        nameFilters: ["Neo files (*.neo)", "All files (*)"]
        property var states: ({
                                  loading: function (fileName) {
                                      room.clearAll()
                                      if (fileName !== undefined) {
                                          room.backend.load(fileName)
                                      }
                                  },
                                  saving: function (fileName) {
                                      if (fileName !== undefined) {
                                          room.backend.save(fileName)
                                      } else {
                                          room.backend.save()
                                      }
                                  }
                              })
        property string state: "loading"

        selectMultiple: false
        selectExisting: false
        selectFolder: false

        onAccepted: {
            states[state](fileDialog.fileUrl)
            close()
        }
    }

    MessageDialog {
        id: confirmDialog
        title: "generic title"
        text: "Is this a question?"
        property var proceed: undefined
        modality: Qt.WindowModal
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        icon: StandardIcon.Question

        onAccepted: {
            close()
            proceed()
        }

        function confirmAndProceed(action, title, text) {
            proceed = action
            confirmDialog.title = title
            confirmDialog.text = text
            open()
        }
    }
}
