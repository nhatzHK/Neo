#pragma once

#include <QObject>
#include <QJsonObject>
#include <QHash>
#include "node.h"

class Connection: public QObject {
    Q_OBJECT

    Q_PROPERTY(Node* to READ receiver WRITE setReceiver NOTIFY receiverChanged)
    Q_PROPERTY(Node* from READ sender WRITE setSender NOTIFY senderChanged)
public:
    explicit Connection(QObject* parent = nullptr);

    Node* receiver() const;
    Node* sender() const;
    void setReceiver(Node* n);
    void setSender(Node* n);

    void read(const QJsonObject& json, const QHash<qulonglong, Node*>& hash);
    QJsonObject write() const;

signals:
    void receiverChanged();
    void senderChanged();

private:

    Node* m_receiver;
    Node* m_sender;
};
