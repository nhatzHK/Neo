#include "connection.h"

Connection::Connection(QObject *parent) {

}

Node* Connection::in() {
    return m_in;
}

Node* Connection::out() {
    return m_out;
}

void Connection::setIn(Node* n) {
    m_in = n;
    emit inChanged();
}

void Connection::setOut(Node* n) {
    m_out = n;
    emit outChanged();
}
