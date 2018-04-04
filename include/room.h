#ifndef ROOM_H
#define ROOM_H

#include <QObject>
#include <QQmlListProperty>
#include <QVariantList>
#include "node.h"
#include "connection.h"

class Room : public QObject {
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Connection> connections READ connections)
    Q_PROPERTY(QQmlListProperty<Node> nodes READ nodes)
    Q_PROPERTY(QStringList ids READ ids)

public:
    explicit Room(QObject * parent = nullptr);

    QQmlListProperty<Connection> connections();
    QQmlListProperty<Node> nodes();
    QStringList ids();

    Q_INVOKABLE bool deleteNode(Node* n);
    Q_INVOKABLE bool connected(Node* a, Node* b, int t);
    Q_INVOKABLE void removeAllConnections(Node* a, Node* b, int t);
    Q_INVOKABLE void createConnection(Node* a, Node* b, int t);
    Q_INVOKABLE bool hasOutConnection(Node* n);
    Q_INVOKABLE bool hasInConnection(Node* n);
    void removeAllConnections(Node* n);

signals:
    void nodeDeleted();
    void connectionBroken();

private:
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
};
#endif // ROOM_H
