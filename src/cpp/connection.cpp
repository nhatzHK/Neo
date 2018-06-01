#include "connection.h"

Connection::Connection(QObject* parent) {}

Node*
Connection::receiver() const
{
  return m_receiver;
}

Node*
Connection::sender() const
{
  return m_sender;
}

void
Connection::setReceiver(Node* n)
{
  m_receiver = n;
  emit receiverChanged();
}

void
Connection::setSender(Node* n)
{
  m_sender = n;
  emit senderChanged();
}

void
Connection::read(const QJsonObject& json, const QHash<qulonglong, Node*>& hash)
{
  if (json.contains("sender") && json["sender"].isString()) {
    qulonglong id = json["sender"].toString().toULongLong();
    if (hash.contains(id)) {
      setSender(hash[id]);
    }
  }

  if (json.contains("receiver") && json["receiver"].isString()) {
    qulonglong id = json["receiver"].toString().toULongLong();
    if (hash.contains(id)) {
      setReceiver(hash[id]);
    }
  }
}

QJsonObject
Connection::write() const
{
  QJsonObject json;
  json["sender"] = QString::number(m_sender->id());
  json["receiver"] = QString::number(m_receiver->id());
  return json;
}
