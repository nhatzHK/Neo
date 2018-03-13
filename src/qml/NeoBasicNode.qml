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

    property var connections: [] //! Array of outgoing connections this node have
    property var elements: [] //! Array of elements declared in the main window

    property bool hasIn: false //! Does the node have incoming connection currectly
    property bool hasOut: connections.length > 0 //! Does the node have outgoing connections currently

    property Item inSlot: NeoRadioButton {
        //visible: hasIn
        y: node.height / 4
        x: -10
        parent: group.contentItem // one group for the node
    }
    property Item outSlot: NeoRadioButton {
        y: node.height / 4
        x: node.width - 13
        //visible: connections.length > 0 ? true: false
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
    }

    /*! Create an array of checkable menu items to display.
        \param type Type of connection to create
    */
    function updateConnectableList(type) {
        var menu
        switch (type) {
        case "in":
            clearMenu(menuConnectIn)
            menu = menuConnectIn
            break
        case "out":
            clearMenu(menuConnectOut)
            menu = menuConnectOut
            break
        default:
            errorBadType(type)
            return
        }

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
            var breaking = false
            if (elements[i] === node) {
                breaking = true
            }

            if (!breaking) {

                // is the element in the connection array of this node
                var inConnections = false
                for (var j = 0; j < connections.length; ++j) {
                    if (elements[i] === connections[j]) {
                        inConnections = true
                        break
                    }
                }
                // is this node in the connection array of the element
                for (var k = 0; k < elements[i].connections.length; ++k) {
                    if (elements[i].connections[k] === node) {
                        inConnections = true
                        break
                    }
                }

                // create menu item
                if (dynamicMenuItem.status === Component.Ready) {
                    const mnuItem = dynamicMenuItem.createObject(contextMenu)

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
                                addConnection(elements[i])
                            } else {
                                removeConnection(elements[i])
                            }
                            break
                        case "out":
                            if (checked) {
                                elements[i].addConnection(node)
                            } else {
                                elements[i].removeConnection(node)
                            }

                            break
                        }

                        canvas.baseCanvas.requestPaint()
                    })
                }
            }
            rec_for(elements, i + 1)
        }
        rec_for(elements, 0)
    }

    /*! \brief Add item to the connection array.
        \param item Nodee to be added as an outgoing connection.
    */
    function addConnection(item) {
        item.connections.push(node)
    }

    /*! \brief Remove item from the connection array.
        \param item Node to be removed from the connection array.
    */
    function removeConnection(item) {
        item.connections.pop(node)
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
    function errorBadtype(type) {
        console.log("[NeoBasicNode] Bad 'type' parameter. Should be 'in' or 'out', but is '"
                    + type + "'.")
    }
}
