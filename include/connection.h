#pragma once

#include <QObject>
#include <QVariant>
#include "node.h"

class Connection: public QObject {
    Q_OBJECT

    Q_PROPERTY(Node* to READ receiver WRITE setReceiver NOTIFY receiverChanged)
    Q_PROPERTY(Node* from READ sender WRITE setSender NOTIFY senderChanged)
public:
    explicit Connection(QObject* parent = nullptr);

    Node* receiver();
    Node* sender();
    void setReceiver(Node* n);
    void setSender(Node* n);

signals:
    void receiverChanged();
    void senderChanged();

private:

    Node* m_receiver;
    Node* m_sender;
};
