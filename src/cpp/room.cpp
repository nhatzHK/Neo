#include "room.h"
#include <QDebug>

Room::Room(QObject *parent) {
    if(!mq_listId.prepare("SELECT id FROM components")) {
        qDebug() << "DB PREPARE ERROR: (room - ctor)" << mq_listId.lastError().text() << '\n';
    }
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
    ((Room*)l->object)->m_nodes.append(n);
    emit ((Room*)l->object)->nodesUpdated();
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

QStringList Room::ids() {
    QStringList l;
    if(!mq_listId.exec()) {
        qDebug() << "DB EXEC ORDER: (listId)" << mq_listId.lastError().text() << '\n';
    }

    while (mq_listId.next()) {
        l.append(mq_listId.value(0).toString());
    }

    return l;
}

bool Room::deleteNode(Node *n) {
    removeAllConnections(n);
    auto b = m_nodes.removeOne(n);
    nodesUpdated ();
    emit connectionsUpdated ();
    return b;
}


void Room::removeAllConnections(Node* n) {
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

    switch (a->type ()) {
    case Node::Output:
        c->setReceiver(a);
        c->setSender(b);
        break;
    case Node::Input:
        c->setReceiver(b);
        c->setSender(a);
        break;
    default:
        switch (t) {
        case Node::Input:
            c->setReceiver (a);
            c->setSender (b);
            break;
        case Node::Output:
            c->setReceiver (b);
            c->setSender (a);
            break;
        }
        break;
    }

    m_connections.append(c);
}

bool Room::connected(Node *a, Node *b) {
    for(auto c: m_connections) {

        if ((a == c->receiver () && b == c->sender ()) || (a == c->sender () && b == c->receiver ())) {
            return true;
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

void Room::removeAllConnections(Node* a, Node* b) {
    QMutableListIterator<Connection*> it(m_connections);

    while(it.hasNext()) {
        auto c = it.next();
        if((c->receiver () == a && c->sender () == b) ||
                (c->sender () == a && c->receiver () == b)) {
            it.remove ();
        }
    }

    emit connectionsUpdated();
}

void Room::evaluate (Node *n) {
    switch (n->type ()) {
    case Node::AndGate:
    case Node::Output:
        if(hasInConnection (n)) {
            for (auto c: m_connections) {
                if(!(c->sender ()->output ()) && c->receiver () == n) {
                    n->setOutput (false);
                    return;
                }
            }
            n->setOutput (true);
            return;
        }
        n->setOutput (false);
        break;
    case Node::OrGate:
        if(hasInConnection (n)) {
            for (auto c: m_connections) {
                if ((c->sender ()->output ()) && c->receiver () == n) {
                    n->setOutput (true);
                    return;
                }
            }
        }
        n->setOutput (false);
        break;
    }
}
