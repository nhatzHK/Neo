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

class Room : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QQmlListProperty<Connection> connections READ connections NOTIFY
               connectionsUpdated)
  Q_PROPERTY(QQmlListProperty<Node> nodes READ nodes NOTIFY nodesUpdated)
  Q_PROPERTY(QUrl file READ file WRITE setFile NOTIFY fileChanged)

public:
  explicit Room(QObject* parent = nullptr);

  QQmlListProperty<Connection> connections();
  QQmlListProperty<Node> nodes();

  QUrl file() const;
  void setFile(const QUrl& url);

  Q_INVOKABLE bool deleteNode(Node* n);

  Q_INVOKABLE bool connected(Node* a, Node* b, int t = Node::Input);
  Q_INVOKABLE bool canConnect(Node* a, Node* b, int t = Node::Input);

  Q_INVOKABLE void removeConnections(Node* a, Node* b, int t = Node::Input);

  Q_INVOKABLE void createConnection(Node* a, Node* b, int t = Node::Input);

  Q_INVOKABLE bool hasOutConnection(Node* n);

  Q_INVOKABLE bool hasInConnection(Node* n);

  Q_INVOKABLE void evaluate(Node* n);

  Q_INVOKABLE void initSocket();

  Q_INVOKABLE void save();
  Q_INVOKABLE void save(const QUrl& url);
  Q_INVOKABLE void load(const QUrl& url);
  Q_INVOKABLE bool savedBefore() const;
  Q_INVOKABLE bool changesSaved() const;

  Q_INVOKABLE bool hasMoreLoaded() const;
  Q_INVOKABLE void loadNextNode(Node* n);
  Q_INVOKABLE void loadConnections();
  Q_INVOKABLE int nextType();

  void read(const QJsonObject& json);
  QJsonObject write() const;
signals:
  void nodeDeleted();
  void connectionBroken();

  void connectionsUpdated();
  void nodesUpdated();

  void fileChanged();

  void roomHaveChanged();
  void roomLoaded();

private:
  void removeConnections(Node* n);
  bool getValue(Node* n);
  void processBundle(OscBundle* bundle);
  void processMessage(OscMessage* message);
  bool looping(Node* a, Node* b, int t);
  bool networkLoop(Node* a, Node* b, int t);
  bool chained(Node* a, Node* b);

  static void clearNodes(QQmlListProperty<Node>*);
  static void clearConnections(QQmlListProperty<Connection>*);

  static void addNode(QQmlListProperty<Node>*, Node*);
  static void addConnection(QQmlListProperty<Connection>*, Connection*);

  static int countNodes(QQmlListProperty<Node>*);
  static int countConnections(QQmlListProperty<Connection>*);

  static Node* getNode(QQmlListProperty<Node>*, int);
  static Connection* getConnection(QQmlListProperty<Connection>*, int);

  QList<Connection*> m_connections;
  QList<Node*> m_nodes;

  QJsonArray m_jsonNodes;
  QJsonArray m_jsonConnections;
  QHash<qulonglong, Node*> m_nodeHash;

  QUdpSocket* m_sock;
  QFile m_file;
  bool m_changeSaved = true;

private slots:
  void readPendingDatagrams();
  void sendMessage(Node*);
};
