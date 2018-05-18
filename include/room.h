#pragma once

#include <QObject>
#include <QQmlListProperty>
#include "node.h"
#include "connection.h"
#include <QUdpSocket>
#include <QNetworkDatagram>

class Room : public QObject {
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Connection> connections READ connections NOTIFY connectionsUpdated)
    Q_PROPERTY(QQmlListProperty<Node> nodes READ nodes NOTIFY nodesUpdated)
    Q_PROPERTY(QStringList ids READ ids NOTIFY idsUpdated)

public:
    explicit Room(QObject * parent = nullptr);

    QQmlListProperty<Connection> connections();
    QQmlListProperty<Node> nodes();
    QStringList ids();

    Q_INVOKABLE bool deleteNode(Node* n);

    Q_INVOKABLE bool connected(Node* a, Node* b, int t = Node::Input);

    Q_INVOKABLE void removeConnections (Node* a, Node* b, int t = Node::Input);

    Q_INVOKABLE void createConnection(Node* a, Node* b, int t = Node::Input);

    Q_INVOKABLE bool hasOutConnection(Node* n);

    Q_INVOKABLE bool hasInConnection(Node* n);

    Q_INVOKABLE void evaluate(Node* n);

signals:
    void nodeDeleted();
    void connectionBroken();

    void connectionsUpdated();
    void nodesUpdated();
    void idsUpdated();

    void paint();

private:
    void removeConnections (Node *n);
    bool getValue (Node *n);
    void initSocket();

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
    QSqlQuery mq_listId;
    QUdpSocket* m_sock;
    QTimer* m_udpTimer;

private slots:
    void readPendingDatagrams();
};
