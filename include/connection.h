#pragma once

#include <QObject>
#include <QVariant>
#include "node.h"

class Connection: public QObject {
    Q_OBJECT

    Q_PROPERTY(Node* to READ in WRITE setIn NOTIFY inChanged)
    Q_PROPERTY(Node* from READ out WRITE setOut NOTIFY outChanged)
public:
    explicit Connection(QObject* parent = nullptr);

    Node* in();
    Node* out();
    void setIn(Node* n);
    void setOut(Node* n);

signals:
    void inChanged();
    void outChanged();

private:

    Node* m_in;
    Node* m_out;
};
