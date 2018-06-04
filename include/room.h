#pragma once

#include <QException>
#include <QFile>
#include <QHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkDatagram>
#include <QObject>
#include <QQmlListProperty>
#include <QUdpSocket>
#include <QUrl>

#include "connection.h"
#include "node.h"

#include "osc/OscPatternMatching.h"
#include "osc/composer/OscMessageComposer.h"
#include "osc/reader/OscBundle.h"
#include "osc/reader/OscContent.h"
#include "osc/reader/OscMessage.h"
#include "osc/reader/OscReader.h"

/*!
 * \class Room
 * \brief Backend class representing a room.
 *
 *  This class manages the interactions with and between nodes as well as the
 * writing and reading of files from/to memory.
 */
class Room : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QQmlListProperty<Connection> connections READ connections NOTIFY
               connectionsUpdated) /*!< \see Room::connections */
  Q_PROPERTY(QQmlListProperty<Node> nodes READ nodes NOTIFY
               nodesUpdated) /*!< \see Room::nodes */
  Q_PROPERTY(QUrl file READ file WRITE setFile NOTIFY
               fileChanged) /*!< \see Room::file */

public:
  /*!
   * \brief Default constructor.
   * \param parent Parent of the room to create.
   */
  explicit Room(QObject* parent = nullptr);

  /*!
   * \brief Getter method to expose the list of connections to QML.
   * \return A list of all the connections created in this room.
   */
  QQmlListProperty<Connection> connections();

  /*!
   * \brief Getter method to expose the list of nodes to QML.
   * \return A list of all the nodes created in this room.
   */
  QQmlListProperty<Node> nodes();

  /*!
   * \brief Getter method to expose the file used for saving to QML.
   * \return The url of the current file in which changes are to be saved.
   */
  QUrl file() const;

  /*!
   * \brief Setter to change the file in which changes are to be saved.
   * \param url The url of the new file.
   */
  void setFile(const QUrl& url);

  /*!
   * \brief QML exposed method to remove nodes from the room.
   * \param node The node to be deleted.
   * \return Return true if a node have been successfully deleted.
   * \see Connection
   * \see Room::removeConnections
   * \see Room::connected
   */
  Q_INVOKABLE bool deleteNode(Node* node);

  /*!
   * \brief Checks if two nodes are connected in a certain direction.
   * \param a first node
   * \param b second node
   * \param direction of the connection
   * \return Return if the two nodes are connected in the specified direction.
   * \see Room::canConnect
   * \see Node::Type
   */
  Q_INVOKABLE bool connected(Node* a, Node* b, int direction = Node::Input);

  /*!
   * \brief Checks all conditions before connecting two nodes.
   * \see Room::connected
   * \param a first node
   * \param b second node
   * \param direction Direction of the connection
   * \return Return true if connecting the two nodes would generate no logic
   * issue, such as loops.
   */
  Q_INVOKABLE bool canConnect(Node* a, Node* b, int direction = Node::Input);

  /*!
   * \brief Breaks any connections between two nodes in a certain direction.
   * \see Room::connected
   * \param a first node
   * \param b second node
   * \param direction Direction of the connection
   * \see Room::connected
   */
  Q_INVOKABLE void removeConnections(Node* a, Node* b, int t = Node::Input);

  /*!
   * \brief Establish a connection between two nodes in a certain direction.
   * \see Room::connected
   * \param a first node
   * \param b second node
   * \param direction Direction of the connection
   * \see Room::connected
   */
  Q_INVOKABLE void createConnection(Node* a, Node* b, int t = Node::Input);

  /*!
   * \brief Check if a node is the sender in any connection in the room.
   * \param node The node to check
   * \return Return true if the node is part of any connection in the room as
   * the sender.
   */
  Q_INVOKABLE bool hasOutConnection(Node* node) const;

  /*!
   * \brief Check if a node is the receiver in any connection in the room.
   * \param node The node to check
   * \return Return true if the node is part of any connection in the room as
   * the receiver.
   */
  Q_INVOKABLE bool hasInConnection(Node* node) const;

  /*!
   * \brief Change the output value of a node based on connections and the
   * nodes' configuration.
   *
   * \param node The node to evaluate
   */
  Q_INVOKABLE void evaluate(Node* node);

  /*!
   * \brief Initalize the udp socket to read and send osc messages.
   */
  Q_INVOKABLE void initSocket();

  /*!
   * \brief Save changes made to the room in a file.
   * \see Room::m_file
   * \see Room::setFile
   */
  Q_INVOKABLE void save();

  /*!
   * \brief Save changes made to the room in a file.
   * \overload Room::save
   * \see Room::save
   */
  Q_INVOKABLE void save(const QUrl& url);

  /*!
   * \brief Loaded the content of a file
   * \see Room::loadNextNode
   * \see Room::loadConnections
   */
  Q_INVOKABLE void load(const QUrl& url);

  /*!
   * \brief Checks if the room have been saved before.
   * \return Return true if the room have been saved.
   * \see Room::save
   */
  Q_INVOKABLE bool savedBefore() const;

  /*!
   * \brief Checks if the room has unsaved changed.
   * \return Return true if the room have not been modified since the last
   * write.
   *
   * \see Room::savedBefore
   * \see Room::save
   */
  Q_INVOKABLE bool changesSaved() const;

  /*!
   * \brief Check if there are more json objects to load.
   * \return Return true if the list Room::m_jsonNodes is not
   * empty.
   */
  Q_INVOKABLE bool hasMoreLoaded() const;

  /*!
   * \brief Load the next json object, if any, into a node.
   * \param node The node in which the next json object should be read.
   * \see Room::hasMoreLoaded
   */
  Q_INVOKABLE void loadNextNode(Node* node);

  /*!
   * \brief Load all the connections loaded as json object into Connection
   * objects.
   * \see Room::load
   * \see Room::loadNextNode
   */
  Q_INVOKABLE void loadConnections();

  /*!
   * \brief Get the type of the next node, if any, to be read into a Node
   *        object.
   * \return Return the type of the next json object to be read.
   * \see Node::Type
   * \see Node::hasMoreLoaded
   */
  Q_INVOKABLE int nextType();

  /*!
   * \brief Read a json object into the room.
   * \param json JSON object to be read.
   */
  void read(const QJsonObject& json);

  /*!
   * \brief Serialize the room.
   * \return Return the JSON object containing the data.
   */
  QJsonObject write() const;

signals:
  void connectionsUpdated(); /*!< Notify a change in the list of connections. */
  void nodesUpdated();       /*!< Notify a change in the list of connections. */

  void fileChanged(); /*!< Notify when the default file has changed. */

  void roomHaveChanged(); /*!< Notify when the room have changed. Used to relay
                             change in individual nodes to the room. */
  void roomLoaded(); /*!< Notify when the reading of a file have completed. */

private:
  /*!
   * \brief Remove all connections the specified node is part of, either as
   * sender or receiver.
   *
   * Useful to clean up before deleting a node.
   * \param node The node to clean.
   */
  void removeConnections(Node* node);

  /*!
   * \brief Getter to read the output of a node.
   * \param node The node to be evaluated.
   * \return Returns the output value of the node.
   * \see Room::evaluate
   */
  bool getValue(Node* node) const;

  /*!
   * \brief Read the content of a bundle and update the room.
   * \param bundle The bundle to read.
   */
  void processBundle(OscBundle* bundle);

  /*!
   * \brief Read the content of a message and update the room.
   * \param message The message to read.
   */
  void processMessage(OscMessage* message);

  /*!
   * \brief Check if a connection between to nodes would create a loop.
   * \param a The first node.
   * \param b The second node.
   * \param direction The direction of the connection.
   * \return Return true if the connection would create a loop.
   * \see Romm::canConnect
   */
  bool looping(Node* a, Node* b, int direction);

  /*!
   * \brief Check if a connection between two nodes would create a network loop.
   * \param a The first node.
   * \param b The second node.
   * \param direction The direction of the connection.
   * \return Return true if the connection would generate a network loop.
   */
  bool networkLoop(Node* a, Node* b, int direction);

  /*!
   * \brief Check if two nodes are part of the same chain of connection.
   * \param a The first node.
   * \param b The second node.
   * \return Return true if the two ndoes are connected.
   */
  bool chained(Node* a, Node* b);

  /*!
   * \brief Clear a list of nodes.
   * \param list The list to be cleared.
   */
  static void clearNodes(QQmlListProperty<Node>* list);

  /*!
   * \brief Clear a list of connections.
   * \param list The list to be cleared.
   */
  static void clearConnections(QQmlListProperty<Connection>* list);

  /*!
   * \brief Add a Node object to a list.
   * \param list The list to add the node to.
   * \param node The node to add to the list.
   */
  static void addNode(QQmlListProperty<Node>* list, Node* node);

  /*!
   * \brief Add a Connection object to a list.
   * \param list The list to add the connection to.
   * \param connection The connection to add to the list.
   */
  static void addConnection(QQmlListProperty<Connection>* list,
                            Connection* connection);

  /*!
   * \brief Get the length of a list of nodes.
   * \param list The list to get the length of.
   * \return Return the length of the list.
   */
  static int countNodes(QQmlListProperty<Node>* list);

  /*!
   * \brief Get the length of a list of connections.
   * \param list The list to get the length of.
   * \return Return the length of the list.
   */
  static int countConnections(QQmlListProperty<Connection>* list);

  /*!
   * \brief Get a node from a list.
   * \param list The list from which to get the node.
   * \param index The index of the node to get.
   * \return Return the node at the specified position in the list.
   */
  static Node* getNode(QQmlListProperty<Node>* list, int index);

  /*!
   * \brief Get a connection from a list.
   * \param list The list from which to get the connection.
   * \param index The index of the connection to get.
   * \return Return the connection at the specified position in the list.
   */
  static Connection* getConnection(QQmlListProperty<Connection>* list,
                                   int index);

  QList<Connection*>
    m_connections;      /*!< List of connections created in the room. */
  QList<Node*> m_nodes; /*!< List of nodes created in the room. */

  QJsonArray m_jsonNodes; /*!< List of nodes loaded but not yet created. */
  QJsonArray
    m_jsonConnections; /*!< List of connections loaded but not yet created. */
  QHash<qulonglong, Node*>
    m_nodeHash; /*!< Hashmap used to rebuild the connections from loaded items.
                   -- (pointer swizzling) */

  QUdpSocket* m_sock; /*!< Socket to listen for OSC messages. */
  QFile m_file; /*!< File in which changes are to be saved. \see Room::save */
  bool m_changeSaved = true; /*!< Boolean holding wether there are unsaved
                                changes in the room currently */

private slots:
  /*!
   * \brief Read pending UDP datagrams.
   */
  void readPendingDatagrams();

  /*!
   * \brief Send an OSC message based on information in a node.
   * \param node The node from which the content of the message is retrieved.
   */
  void sendMessage(Node* node);
};
