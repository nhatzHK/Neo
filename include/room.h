#pragma once

#include <QObject>
#include <QQmlListProperty>
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QException>

#include "node.h"
#include "connection.h"

#include "osc/composer/OscMessageComposer.h"
#include "osc/reader/OscReader.h"
#include "osc/reader/OscMessage.h"
#include "osc/reader/OscBundle.h"
#include "osc/reader/OscContent.h"
#include "osc/OscPatternMatching.h"


class Room : public QObject {
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Connection> connections READ connections NOTIFY connectionsUpdated)
    Q_PROPERTY(QQmlListProperty<Node> nodes READ nodes NOTIFY nodesUpdated)

public:
    explicit Room(QObject * parent = nullptr);

    QQmlListProperty<Connection> connections();
    QQmlListProperty<Node> nodes();

    Q_INVOKABLE bool deleteNode(Node* n);

    Q_INVOKABLE bool connected(Node* a, Node* b, int t = Node::Input);

    Q_INVOKABLE void removeConnections (Node* a, Node* b, int t = Node::Input);

    Q_INVOKABLE void createConnection(Node* a, Node* b, int t = Node::Input);

    Q_INVOKABLE bool hasOutConnection(Node* n);

    Q_INVOKABLE bool hasInConnection(Node* n);

    Q_INVOKABLE void evaluate(Node* n);

    Q_INVOKABLE void initSocket();

    Q_INVOKABLE void save();


    void processBundle(OscBundle* bundle);
    void processMessage(OscMessage* message);

signals:
    void nodeDeleted();
    void connectionBroken();

    void connectionsUpdated();
    void nodesUpdated();

    void paint();

private:
    void removeConnections (Node *n);
    bool getValue (Node *n);

    static void clearNodes(QQmlListProperty<Node>*);
    static void clearConnections(QQmlListProperty<Connection>*);

    static void addNode(QQmlListProperty<Node>*, Node*);
    static void addConnection(QQmlListProperty<Connection>*, Connection*);

    static int countNodes(QQmlListProperty<Node>*);
    static int countConnections(QQmlListProperty<Connection>*);

    static Node* getNode(QQmlListProperty<Node> *, int);
    static Connection* getConnection(QQmlListProperty<Connection>*, int);

    QList<Connection*> m_connections;
    QList<Node*> m_nodes;
    QUdpSocket* m_sock;

private slots:
    void readPendingDatagrams();
    void sendMessage(Node*);
};
