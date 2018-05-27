#include "room.h"
#include <QDebug>

Room::Room(QObject *parent) {
}

void Room::clearNodes(QQmlListProperty<Node>* l) {
    ((Room*)l->object)->m_nodes.clear();
    emit ((Room*)l->object)->nodesUpdated();
}

void Room::clearConnections(QQmlListProperty<Connection>* l) {
    ((Room*)l->object)->m_connections.clear();
    emit ((Room*)l->object)->connectionsUpdated();
}

void Room::addNode(QQmlListProperty<Node>* l,  Node* n) {
    auto r = (Room*)(l->object);
    r->m_nodes.append(n);
    connect (n, &Node::messageReady, r, &Room::sendMessage);
    emit r->nodesUpdated();
}

void Room::addConnection(QQmlListProperty<Connection> *l, Connection *c) {
    ((Room*)l->object)->m_connections.append(c);
    emit ((Room*)l->object)->connectionsUpdated();
}

int Room::countNodes(QQmlListProperty<Node>* l) {
    return ((Room*)l->object)->m_nodes.length();
}

int Room::countConnections(QQmlListProperty<Connection> *l) {
    return ((Room*)l->object)->m_connections.length();
}

Node* Room::getNode(QQmlListProperty<Node>* l,  int i) {
    return ((Room*)l->object)->m_nodes.at(i);
}

Connection* Room::getConnection(QQmlListProperty<Connection> *l, int i) {
    return ((Room*)l->object)->m_connections.at(i);
}



QQmlListProperty<Node> Room::nodes() {
    return QQmlListProperty<Node>(this, &m_nodes,
                                  &Room::addNode,
                                  &Room::countNodes,
                                  &Room::getNode,
                                  &Room::clearNodes);
}

QQmlListProperty<Connection> Room::connections() {
    return QQmlListProperty<Connection>(this, &m_connections,
                                        &Room::addConnection,
                                        &Room::countConnections,
                                        &Room::getConnection,
                                        &Room::clearConnections);
}

bool Room::deleteNode(Node *n) {
    removeConnections(n);
    auto b = m_nodes.removeOne(n);
    nodesUpdated ();
    emit connectionsUpdated ();
    return b;
}

void Room::removeConnections(Node* n) {
    QMutableListIterator<Connection*> it(m_connections);
    while (it.hasNext()) {
        auto c =  it.next();
        if(c->receiver() == n || c->sender () == n) {
            it.remove();
        }
    }
    emit connectionsUpdated();
}

void Room::createConnection(Node* a, Node* b, int t) {
    Connection* c = new Connection();

    QVariant av = QVariant::fromValue(a);
    QVariant bv = QVariant::fromValue(b);

    switch (t) {
    case Node::Input:
        c->setSender (a);
        c->setReceiver (b);
        break;
    case Node::Output:
        c->setSender (b);
        c->setReceiver (a);
        break;
    }

    m_connections.append(c);
}

bool Room::connected(Node *a, Node *b, int t) {
    for(auto c: m_connections) {

        switch (t) {
        case Node::Input:
            if (c->sender () == a && c->receiver () == b) {
                return true;
            }
            break;
        case Node::Output:
            if(c->sender () == b && c->receiver () == a) {
                return true;
            }
            break;
        }
    }
    return false;
}

bool Room::hasInConnection(Node *n) {
    if(n->type() == Node::Input) {
        return false;
    }

    for (auto c: m_connections) {
        if(c->receiver () == n) {
            return true;
        }
    }

    return false;
}

bool Room::hasOutConnection(Node *n) {

    if(n->type () == Node::Output) {
        return false;
    }

    for (auto c: m_connections) {
        if(c->sender () == n) {
            return true;
        }
    }

    return false;
}

void Room::removeConnections (Node *a, Node *b, int t) {
    QMutableListIterator<Connection*> it(m_connections);

    while(it.hasNext ()) {
        auto c = it.next ();
        switch (t) {
        case Node::Input:
            if(c->sender () == a && c->receiver () == b) {
                it.remove ();
            }
            break;
        case Node::Output:
            if(c->sender () == b && c->receiver () == a) {
                it.remove ();
            }
            break;
        }
    }
}

bool Room::getValue(Node *n) {

    if(!n->opened ()) {
        return false;
    }

    bool res = false;
    bool done = false;
    switch (n->type ()) {
    case Node::AndGate:
    case Node::Output:
        if(hasInConnection (n)) {
            for (auto c: m_connections) {
                if(!(c->sender ()->output ()) && c->receiver () == n) {
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
        if(hasInConnection (n)) {
            for (auto c: m_connections) {
                if ((c->sender ()->output ()) && c->receiver () == n) {
                    res = true;
                    done = true;
                    break;
                }
            }
        }
        break;
    case Node::Input:
        res = n->value () <= n->second () && n->value () >= n->first ();
        done = true;
    }

    return res ^ n->inverted ();
}

void Room::evaluate (Node *n) {
    n->setOutput (getValue(n));

    for(auto c: m_connections) {
        if(c->sender () == n) {
            c->receiver ()->connectionsHaveChanged ();
        }
    }
}

void Room::initSocket() {
    m_sock = new QUdpSocket(this);
    if (m_sock->bind(QHostAddress::LocalHost, 8888)) {
        connect(m_sock, SIGNAL(readyRead()),
                this, SLOT(readPendingDatagrams()));
    } else {
        qDebug() << "BIND SOCKET ERROR: (room - initSocket)Failed to bind socket.\n";
    }
}

void Room::readPendingDatagrams() {

    while (m_sock->hasPendingDatagrams()) {
        QNetworkDatagram dg(m_sock->receiveDatagram ());

        try{
            OscReader reader(new QByteArray(dg.data ()));

            if (reader.getContentType () == OscContent::Bundle) {
                processBundle(reader.getBundle ());
            } else {
               processMessage(reader.getMessage ());
            }
        } catch(QException& qe) {
            qDebug() << qe.what () << '\n';
        }
    }
}

void Room::sendMessage(Node* n) {
    OscMessageComposer mc(n->address ());
    mc.pushDouble (n->value ());
    m_sock->writeDatagram (*(mc.getBytes ()), n->getIp(), n->getPort());
}

void Room::processBundle(OscBundle* bundle) {
    for(size_t i = 0; i < bundle->getNumEntries (); ++i) {
        if(bundle->getType (i) == OscContent::Bundle) {
            processBundle (bundle->getBundle (i));
        } else {
            processMessage (bundle->getMessage (i));
        }
    }
}

void Room::processMessage(OscMessage* message) {

    int match_node = 0;
    int match_message = 0;

    for (auto n: m_nodes) {
        int r = OSCPatternMatching::osc_match(n->address ().toStdString ().c_str (),
                                                message->getAddress ().toStdString ().c_str (), match_node, match_message);

        if (match_node == n->address ().length () && message->getNumValues () > 0) {
            n->setValue (message->getValue (0)->toDouble ());
        }
    }
}

void Room::save () {
    qDebug() << "Saving room\n";

}
