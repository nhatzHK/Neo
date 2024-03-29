#include "room.h"
#include <QDebug>

/*!
 */
Room::Room(QObject* parent)
{
  connect(this, &Room::roomHaveChanged, [=]() { this->m_changeSaved = false; });
}

/*!
 */
void
Room::clearNodes(QQmlListProperty<Node>* l)
{
  ((Room*)l->object)->m_nodes.clear();
  emit((Room*)l->object)->nodesUpdated();
}

/*!
 */
void
Room::clearConnections(QQmlListProperty<Connection>* l)
{
  ((Room*)l->object)->m_connections.clear();
  emit((Room*)l->object)->connectionsUpdated();
}

/*!
 */
void
Room::addNode(QQmlListProperty<Node>* l, Node* n)
{
  auto r = (Room*)(l->object);
  r->m_nodes.append(n);
  connect(n, &Node::messageReady, r, &Room::sendMessage);
  connect(n, &Node::nodeHaveChanged, r, &Room::roomHaveChanged);
  emit r->nodesUpdated();
}

/*!
 */
void
Room::addConnection(QQmlListProperty<Connection>* l, Connection* c)
{
  ((Room*)l->object)->m_connections.append(c);
  emit((Room*)l->object)->connectionsUpdated();
}

/*!
 */
int
Room::countNodes(QQmlListProperty<Node>* l)
{
  return ((Room*)l->object)->m_nodes.length();
}

/*!
 */
int
Room::countConnections(QQmlListProperty<Connection>* l)
{
  return ((Room*)l->object)->m_connections.length();
}

/*!
 */
Node*
Room::getNode(QQmlListProperty<Node>* l, int i)
{
  return ((Room*)l->object)->m_nodes.at(i);
}

/*!
 */
Connection*
Room::getConnection(QQmlListProperty<Connection>* l, int i)
{
  return ((Room*)l->object)->m_connections.at(i);
}

/*!
 */
QQmlListProperty<Node>
Room::nodes()
{
  return QQmlListProperty<Node>(this,
                                &m_nodes,
                                &Room::addNode,
                                &Room::countNodes,
                                &Room::getNode,
                                &Room::clearNodes);
}

/*!
 */
QQmlListProperty<Connection>
Room::connections()
{
  return QQmlListProperty<Connection>(this,
                                      &m_connections,
                                      &Room::addConnection,
                                      &Room::countConnections,
                                      &Room::getConnection,
                                      &Room::clearConnections);
}

/*!
 */
QUrl
Room::file() const
{
  return QUrl(m_file.fileName());
}

/*!
 */
void
Room::setFile(const QUrl& url)
{
  m_file.setFileName(url.toLocalFile());
  emit fileChanged();
}

/*!
 * \details Also breaks any connection involving that node.
 */
bool
Room::deleteNode(Node* n)
{
  removeConnections(n);
  auto b = m_nodes.removeOne(n);
  nodesUpdated();
  emit connectionsUpdated();
  return b;
}

/*!
 */
void
Room::removeConnections(Node* n)
{
  QMutableListIterator<Connection*> it(m_connections);
  while (it.hasNext()) {
    auto c = it.next();
    if (c->receiver() == n || c->sender() == n) {
      it.remove();
    }
  }
  emit connectionsUpdated();
}

/*!
 * \details The parameters behave like Room::connected
 */
void
Room::createConnection(Node* a, Node* b, int t)
{
  // when connecting to output watch out for network loop
  if ((b->type() == Node::Output || a->type() == Node::Output) &&
      networkLoop(a, b, t)) {
    // TODO: display warning in status bar
    return;
  }

  Connection* c = new Connection();

  QVariant av = QVariant::fromValue(a);
  QVariant bv = QVariant::fromValue(b);

  switch (t) {
    case Node::Input:
      c->setSender(a);
      c->setReceiver(b);
      break;
    case Node::Output:
      c->setSender(b);
      c->setReceiver(a);
      break;
  }

  m_connections.append(c);
}

/*!
 *  \details The \p direction parameter specifies how the other parameters
 * should be interpreted.
 *
 * Possible values:\n
 * - Node::Input\n
 * 	 Indicates that the first parameter (\p a) is the sender in a potential
 * connection.
 * - Node::Output\n
 * 	 Indicates that the first parameter (\p a) is the receiver in a
 * potential connection.
 *
 */
bool
Room::connected(Node* a, Node* b, int t)
{
  for (auto c : m_connections) {

    switch (t) {
      case Node::Input:
        if (c->sender() == a && c->receiver() == b) {
          return true;
        }
        break;
      case Node::Output:
        if (c->sender() == b && c->receiver() == a) {
          return true;
        }
        break;
    }
  }
  return false;
}

/*!
 * \details Mainly to check for possible loops before establishing a connection.
 * The parameters behave like Room::connected.
 */
bool
Room::canConnect(Node* a, Node* b, int t)
{
  // can't connect to self
  if (a == b) {
    return false;
  }

  if (a->type() == b->type()) {
    // only gates can connect to same type
    if (a->type() != Node::AndGate && a->type() != Node::OrGate) {
      return false;
    }
  }

  // gates
  if ((a->type() == Node::AndGate || a->type() == Node::OrGate) &&
      (b->type() == Node::AndGate || b->type() == Node::OrGate)) {
    // watch out for loops when connecting gates to gates
    if (looping(a, b, t)) {
      return false;
    }
  }

  return true;
}

/*!
 * \details The parameters are inteerpreted like in Room::canConnect.
 */
bool
Room::looping(Node* a, Node* b, int t)
{
  if (connected(a, b, t == Node::Input ? Node::Output : Node::Input)) {
    return true;
  }

  if (t == Node::Input) {
    for (auto c : m_connections) {
      if (c->sender() == b && looping(a, c->receiver(), t)) {
        return true;
      }
    }
  } else {
    for (auto c : m_connections) {
      if (c->receiver() == b && looping(a, c->sender(), t)) {
        return true;
      }
    }
  }

  return false;
}

/*!
 * \details A network loop is created when an output node (type Node::Output)
 * and an input node (type Node::Input) are connected and have the same OSC
 * address.
 */
bool
Room::networkLoop(Node* a, Node* b, int t)
{
  if (t == Node::Input) {
    if (a->type() == Node::Input) {
      return a->address() == b->address();
    }

    for (auto c : m_connections) {
      if (c->sender()->type() == Node::Input &&
          c->sender()->address() == b->address() && chained(c->sender(), a)) {
        return true;
      }
    }
  } else {
    if (b->type() == Node::Input) {
      return a->address() == b->address();
    }

    for (auto c : m_connections) {
      if (c->sender()->type() == Node::Input &&
          c->sender()->address() == a->address() && chained(c->sender(), b)) {
        return true;
      }
    }
  }

  return false;
}

/*!
 * \details If \p b can be reached by recursively exploring the connection
 * list starting from \p a, the nodes are considered chained.
 */
bool
Room::chained(Node* a, Node* b)
{
  if (connected(a, b)) {
    return true;
  }

  for (auto c : m_connections) {
    if (c->sender() == a && chained(c->receiver(), b)) {
      return true;
    }
  }

  return false;
}

/*!
 */
bool
Room::hasInConnection(Node* n) const
{
  if (n->type() == Node::Input) {
    return false;
  }

  for (auto c : m_connections) {
    if (c->receiver() == n) {
      return true;
    }
  }

  return false;
}

/*!
 */
bool
Room::hasOutConnection(Node* n) const
{

  if (n->type() == Node::Output) {
    return false;
  }

  for (auto c : m_connections) {
    if (c->sender() == n) {
      return true;
    }
  }

  return false;
}

/*!
 * \details The parameters behave like Room::connected.
 */
void
Room::removeConnections(Node* a, Node* b, int t)
{
  QMutableListIterator<Connection*> it(m_connections);

  while (it.hasNext()) {
    auto c = it.next();
    switch (t) {
      case Node::Input:
        if (c->sender() == a && c->receiver() == b) {
          it.remove();
        }
        break;
      case Node::Output:
        if (c->sender() == b && c->receiver() == a) {
          it.remove();
        }
        break;
    }
  }
}

/*!
 */
bool
Room::getValue(Node* n) const
{

  if (!n->opened()) {
    return false;
  }

  bool res = false;
  bool done = false;
  switch (n->type()) {
    case Node::AndGate:
    case Node::Output:
      if (hasInConnection(n)) {
        for (auto c : m_connections) {
          if (!(c->sender()->output()) && c->receiver() == n) {
            res = false;
            done = true;
            break;
          }
        }
        if (!done) {
          res = true;
          done = true;
        }
      }
      break;
    case Node::OrGate:
      if (hasInConnection(n)) {
        for (auto c : m_connections) {
          if ((c->sender()->output()) && c->receiver() == n) {
            res = true;
            done = true;
            break;
          }
        }
      }
      break;
    case Node::Input:
      res = n->value() <= n->second() && n->value() >= n->first();
      done = true;
  }

  return res ^ n->inverted();
}

/*!
 */
void
Room::evaluate(Node* n)
{
  n->setOutput(getValue(n));

  for (auto c : m_connections) {
    if (c->sender() == n) {
      c->receiver()->connectionsHaveChanged();
    }
  }
}

/*!
 */
void
Room::initSocket()
{
  m_sock = new QUdpSocket(this);
  if (m_sock->bind(QHostAddress::LocalHost, 8888)) {
    connect(m_sock, SIGNAL(readyRead()), this, SLOT(readPendingDatagrams()));
  } else {
    qWarning()
      << "BIND SOCKET ERROR: (room - initSocket)Failed to bind socket.\n";
  }
}

/*!
 */
void
Room::readPendingDatagrams()
{

  while (m_sock->hasPendingDatagrams()) {
    QNetworkDatagram dg(m_sock->receiveDatagram());

    try {
      OscReader reader(new QByteArray(dg.data()));

      if (reader.getContentType() == OscContent::Bundle) {
        processBundle(reader.getBundle());
      } else {
        processMessage(reader.getMessage());
      }
    } catch (QException& qe) {
      qWarning() << qe.what() << '\n';
    }
  }
}

/*!
 */
void
Room::sendMessage(Node* n)
{
  OscMessageComposer mc(n->address());
  mc.pushDouble(n->value());
  m_sock->writeDatagram(*(mc.getBytes()), n->getIp(), n->getPort());
}

/*!
 */
void
Room::processBundle(OscBundle* bundle)
{
  for (size_t i = 0; i < bundle->getNumEntries(); ++i) {
    if (bundle->getType(i) == OscContent::Bundle) {
      processBundle(bundle->getBundle(i));
    } else {
      processMessage(bundle->getMessage(i));
    }
  }
}

/*!
 */
void
Room::processMessage(OscMessage* message)
{
  for (auto n : m_nodes) {
    if (n->type() == Node::Input && n->address() == message->getAddress() &&
        message->getNumValues() > 0) {
      n->setValue(message->getValue(0)->toDouble());
    }
  }
}

/*!
 * \details Serializes every node and connection created in this room and write
 * them to a file.
 *
 * \pre This function assumes a file have been set already by calling
 * Room::setFile.
 *
 */
void
Room::save()
{
  if (!m_file.open(QIODevice::WriteOnly)) {
    qWarning() << "Could not open file: " << m_file.fileName() << '\n';
    return;
  }

  QJsonDocument dataDoc(write());
  m_file.write(dataDoc.toBinaryData());

  m_changeSaved = true;
  m_file.close();
}

/*!
 */
void
Room::save(const QUrl& url)
{
  m_file.setFileName(url.toLocalFile().endsWith(".neo")
                       ? url.toLocalFile()
                       : url.toLocalFile() + ".neo");
  save();
}

/*!
 * \details The content of the file is loaded into json objects.
 *
 * This method does not create instances of Node or Connection for the loaded
 * data.
 *
 * \post The content of the lists Room::m_jsonNodes and Room::m_jsonConnections
 * should be consumed after calling this function.
 */
void
Room::load(const QUrl& url)
{
  QFile file(url.toLocalFile());
  if (!file.open(QIODevice::ReadOnly)) {
    qWarning() << "Could not open file: " << url.toLocalFile();
    return;
  }

  QByteArray dataArray = file.readAll();
  file.close();

  QJsonDocument dataDoc = QJsonDocument::fromBinaryData(dataArray);
  read(dataDoc.object());

  emit roomLoaded();
}

/*!
 * \details This method can be used to determine if a file name have been set
 * before calling Room::save.
 *
 * \pre The room should be cleared of all its nodes and connections before
 * loading new data in it.
 */
bool
Room::savedBefore() const
{
  return m_file.exists();
}

/*!
 */
bool
Room::changesSaved() const
{
  return m_changeSaved;
}

/*!
 */
void
Room::read(const QJsonObject& json)
{

  if (json.contains("nodes") && json["nodes"].isArray()) {
    m_jsonNodes = json["nodes"].toArray();
    m_nodes.clear();
  }

  if (json.contains("connections") && json["connections"].isArray()) {
    m_jsonConnections = json["connections"].toArray();
    m_connections.clear();
    m_nodeHash.clear();
  }
}

/*!
 */
QJsonObject
Room::write() const
{
  QJsonObject json;
  QJsonArray nodeArray;
  for (const auto& n : m_nodes) {
    nodeArray.append(n->write());
  }
  json["nodes"] = nodeArray;

  QJsonArray connectionArray;
  for (const auto& c : m_connections) {
    connectionArray.append(c->write());
  }
  json["connections"] = connectionArray;

  return json;
}

/*!
 * \pre Room::load have to be called before using this method.
 * \post When this returns false, Room::loadConnections should be called
 * immediately after.
 */
bool
Room::hasMoreLoaded() const
{
  return !(m_jsonNodes.isEmpty());
}

/*!
 */
void
Room::loadNextNode(Node* n)
{
  if (!(m_jsonNodes.isEmpty())) {
    n->read(m_jsonNodes.takeAt(0).toObject());
    m_nodeHash.insert(n->id(), n);
    m_nodes.append(n);
    connect(n, &Node::messageReady, this, &Room::sendMessage);
    connect(n, &Node::nodeHaveChanged, this, &Room::roomHaveChanged);
  }
}

/*!
 * \pre Room::load should be called before using this method. All
 * nodes loaded as json objects should have also been loaded into Node objects
 * before calling this.
 */
void
Room::loadConnections()
{
  m_connections.reserve(m_jsonConnections.size());
  for (const auto& json : m_jsonConnections) {
    Connection* c = new Connection();
    c->read(json.toObject(), m_nodeHash);
    m_connections.append(c);
    c->sender()->connectionsHaveChanged();
    c->receiver()->connectionsHaveChanged();
  }
}

/*!
 * \pre Room::hasMoreLoaded have to be used before calling this method to
 * determine if there is more loaded data
 *
 */
int
Room::nextType()
{
  return Node::Type(m_jsonNodes.at(0).toObject()["type"].toInt());
}
