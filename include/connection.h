#ifndef CONNECTION_H
#define CONNECTION_H

#include <QObject>
#include "inputnode.h"

class Connection: public QObject {
    Q_OBJECT

    Q_PROPERTY(Node* in READ in WRITE setIn NOTIFY inChanged)
    Q_PROPERTY(Node* out READ out WRITE setOut NOTIFY outChanged)
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
    Node* m_in = nullptr;
    Node* m_out = nullptr;
};

#endif // CONNECTION_H
