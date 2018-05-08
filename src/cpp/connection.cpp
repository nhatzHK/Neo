#include "connection.h"

Connection::Connection(QObject *parent) {

}

Node* Connection::receiver() {
    return m_receiver;
}

Node* Connection::sender() {
    return m_sender;
}

void Connection::setReceiver(Node* n) {
    m_receiver = n;
    emit receiverChanged();
}

void Connection::setSender(Node* n) {
    m_sender = n;
    emit senderChanged();
}
