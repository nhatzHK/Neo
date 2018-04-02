#include "room.h"
#include <QDebug>

Room::Room(QObject *parent) {

}

bool Room::connected(Node *a, Node *b, int t) {
    for(auto c: m_connections) {
        switch (t) {
        case Node::In:
            if(c->in() == a && c->out() == b) {
                return true;
            }
            break;
        case Node::Out:
            if(c->out() == a && c->in() == b) {
                return true;
            }
            break;
        }
    }

    return false;
}

bool Room::hasInConnection(Node *n) {
    for (auto c: m_connections) {
        if (c->in() == n) {
            return true;
        }
    }
}

bool Room::hasOutConnection(Node *n) {
    for (auto c: m_connections) {
        if(c->out() == n) {
            return true;
        }
    }
}

bool Room::deleteNode(Node *n) {
    removeAllConnections(n);
    return m_nodes.removeOne(n);
}

void Room::removeAllConnections(Node* n) {
   QMutableListIterator<Connection*> it(m_connections);
   while (it.hasNext()) {
       auto c =  it.next();
       if (c->in() == n || c->out() == n) {
           it.remove();
       }
   }
}

void Room::clearNodes(QQmlListProperty<Node>* l) {
    return ((Room*)l->object)->m_nodes.clear();
}

void Room::clearConnections(QQmlListProperty<Connection>* l) {
    return ((Room*)l->object)->m_connections.clear();
}

void Room::addNode(QQmlListProperty<Node>* l,  Node* n) {
    ((Room*)l->object)->m_nodes.append(n);
}

void Room::addConnection(QQmlListProperty<Connection> *l, Connection *c) {
    ((Room*)l->object)->m_connections.append(c);
}

void Room::createConnection(Node* a, Node* b, int t) {
    Connection* c = new Connection();
    switch (t) {
    case Node::In:
        c->setIn(a);
        c->setOut(b);
        break;
    case Node::Out:
        c->setIn(b);
        c->setOut(a);
        break;
    }

    m_connections.append(c);
}

void Room::removeAllConnections(Node* a, Node* b, int t) {
    QMutableListIterator<Connection*> it(m_connections);
    while(it.hasNext()) {
        auto c = it.next();
        switch (t) {
        case Node::In:
            if(c->in() == a && c->out() == b) {
                it.remove();
            }
            break;
        case Node::Out:
            if(c->out() == a && c->in() == b) {
                it.remove();
            }
            break;
        }
    }
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
