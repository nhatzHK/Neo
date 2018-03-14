import QtQuick 2.2
import QtQuick.Controls 1.4


/*! \file Basic node to build more complex elements on
    Basic node with a in and an out slot to connect.
*/
Rectangle {
    id: node
    x: 210
    y: 34
    width: 130
    height: 58
    color: "lightblue"

    property string name: "Name" //! Name used to connect to the node

    property var outCon: [] //! Array of outgoing connections
    property var inCon: [] //! Array of incoming connections

    property var elements: [] //! Array of elements declared in the main window

    property Item inSlot: NeoRadioButton {
        visible: false
        y: node.height / 4
        x: -10
        parent: group.contentItem // one group for the node
    }
    property Item outSlot: NeoRadioButton {
        y: node.height / 4
        x: node.width - 13
        visible: false
        parent: group.contentItem
    }

    property NeoCanvas canvas: NeoCanvas {
    }

    property Component dynamicMenuItem: null //! Component used to create menu items on demand

    // finish initialization
    Component.onCompleted: {
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
    }

    Drag.active: drag_area.drag.active
    Drag.hotSpot.x: 130 / 2
    Drag.hotSpot.y: 58 / 2

    onXChanged: {
        canvas.baseCanvas.requestPaint()
    }

    onYChanged: {
        canvas.baseCanvas.requestPaint()
    }

    MouseArea {
        id: drag_area
        anchors.fill: parent
        drag.target: parent

        signal rightClick
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        // show context menu on leftclick pressed over the node
        onPressed: {
            if (Qt.RightButton & pressedButtons) {
                contextMenu.popup()
            }
        }
    }

    //! Parent of the radiobuttons used for incoming/outgoing connections
    GroupBox {
        id: group
        anchors.fill: parent
    }

    //! Context menu
    Menu {
        id: contextMenu
        title: qsTr("Node menu")

        Menu {
            title: qsTr("Connect")
            Menu {
                id: menuConnectOut
                title: "Send"

                onAboutToShow: updateConnectableList("out")
            }

            Menu {
                id: menuConnectIn
                title: "Receive"

                onAboutToShow: updateConnectableList("in")
            }
        }

        MenuItem {
            text: "Delete"
            onTriggered: {
                for(var i = 0; i < inCon.length; ++i) {
                    disconnectIn(inCon[i])
                }

                for(var j = 0; j < outCon.length; ++j) {
                    disconnectOut(outCon[j])
                }

                elements.splice(elements.indexOf(node), 1)
                node.destroy()
                canvas.baseCanvas.requestPaint()
            }
        }
    }

    Label {
        anchors.fill: parent
        text: name
        x: parent.width / 2
        y: parent.width / 2
        font.bold: true
        font.pointSize: 20
    }

    /*! \brief Clear content of a menu */
    function clearMenu(menu) {
        menu.items = []
        return menu
    }

    /*! Create an array of checkable menu items to display.
        \param type Type of connection to create
    */
    function updateConnectableList(type) {
        if (type !== "in" && type !== "out") {
            errorBadType(type)
            return
        }

        var menu = type === "in" ? clearMenu(menuConnectIn) : clearMenu(
                                       menuConnectOut)
        var connections = type === "in" ? inCon : outCon

        /*! \brief Recursive loop replacing a for loop.

            Necessary because with a usual for loop, the index (i) is taken by reference
            and not by value. Totally js' fault.
            Considering doing this logic on the C++ side.
            \param elements Array to iterate over
            \param i Index of the iteration (i < arrays.length)
        */
        function rec_for(elements, i) {
            if (i >= elements.length) {
                return
            }

            // do not include **this** node, skip
            var breaking = elements[i] === node

            if (!breaking) {

                // is the element in the connection array of this node
                var inConnections = false
                for (var j = 0; j < connections.length; ++j) {
                    if (elements[i] === connections[j]) {
                        inConnections = true
                        break
                    }
                }

                // create menu item
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(contextMenu)

                    menu.insertItem(0, mnuItem)

                    // set properties in menu item
                    if (inConnections) {
                        mnuItem.checked = true
                    }
                    mnuItem.text = elements[i].name
                    mnuItem.checkable = true

                    // set signal handler

                    /*! \brief Add/remove connection when the menu item is toggled on/off.
                        If the type of connection is in, add it to this node
                        If the type of connection is out, add it to the currently analyzed element
                        from the array of all the nodes.
                    */
                    mnuItem.toggled.connect(function (checked) {
                        switch (type) {
                        case "in":
                            if (checked) {
                                connectIn(elements[i])
                            } else {
                                disconnectIn(elements[i])
                            }
                            break
                        case "out":
                            if (checked) {
                                connectOut(elements[i])
                            } else {
                                disconnectOut(elements[i])
                            }

                            break
                        }

//                        updateSlots()
//                        elements[i].updateSlots()
                        canvas.baseCanvas.requestPaint()
                    })
                }
            }
            rec_for(elements, i + 1)
        }
        rec_for(elements, 0)
    }

    /*! \brief Hide/show connections slots based on the number of connections
       Hide when there is no connection passing through the slot
       Show when there is at least one connection going through the slot
    */
    function updateSlots() {
        outSlot.visible = outCon.length > 0
        inSlot.visible = inCon.length > 0
    }

    /*! \brief Create an incoming connection with the item
        \param item Node that we want to connect to.
        Also create an outgoing connection on the item's side.
    */
    function connectIn(item) {
        inCon.push(item)
        item.outCon.push(node)
        item.updateSlots()
        updateSlots()
    }

    /*! \brief Create an outgoing connection with the item
        \param item Node that we want to connect to.
        Also create an incoming connection on the item's side.
    */
    function connectOut(item) {
        outCon.push(item)
        item.inCon.push(node)
        item.updateSlots()
        updateSlots()
    }

    /*! \brief Break the incoming connection with the item.
        \param item Item currently connected to the node that we wish to disconnect.
        Also break the connection from the item's side.
    */
    function disconnectIn(item) {
        inCon.splice(inCon.indexOf(item), 1)
        item.outCon.splice(item.outCon.indexOf(node), 1)
        item.updateSlots()
        updateSlots()
    }

    /*! \brief Break the outgoing connection with the item.
        \param item Item currently connected to the node that we wish to disconnect.
        Also break the connection from the item's side.
    */
    function disconnectOut(item) {
        outCon.splice(outCon.indexOf(item), 1)
        item.inCon.splice(item.inCon.indexOf(node), 1)
        item.updateSlots()
        updateSlots()
    }

    /*! Return position of slot for outgoing connections. */
    function getInPos() {
        return Qt.point(x + inSlot.x + 8, y + inSlot.y - 6)
    }

    /*! Return position of slot for incoming connection. */
    function getOutPos() {
        return Qt.point(x + outSlot.x + 15, y + outSlot.y - 6)
    }

    /*! Dummy type error logging */
    function errorBadType(type) {
        console.log("[NeoBasicNode] Bad 'type' parameter. Should be 'in' or 'out', but is '"
                    + type + "'.")
    }
}
