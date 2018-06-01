#include "node.h"

Node::Node(QObject* parent)
  : QObject(parent)
{
  connect(this, &Node::conditionOverriden, [=]() { emit messageReady(this); });
  connect(this, &Node::outputChanged, [=]() {
    if (type() == Node::Output && output()) {
      emit messageReady(this);
    }
  });

  m_id = reinterpret_cast<qulonglong>(this);
}

void
Node::setType(const Type& t)
{
  m_type = t;
  emit typeChanged();
  emit nodeHaveChanged();
}

Node::Type
Node::type() const
{
  return m_type;
}

void
Node::setValue(const double& v)
{
  m_value = v;
  emit valueChanged();
  emit nodeHaveChanged();
}

double
Node::value() const
{
  return m_value;
}

QString
Node::name() const
{
  return m_name;
}

void
Node::setName(const QString& n)
{
  m_name = n;
  emit nameChanged();
  emit nodeHaveChanged();
}

QString
Node::address() const
{
  return m_address;
}

void
Node::setAddress(const QString& i)
{
  m_address = i;
  emit addressChanged();
  emit nodeHaveChanged();
}

QPoint
Node::pos() const
{
  return m_pos;
}

void
Node::setPos(const QPoint& p)
{
  m_pos = p;
  emit posChanged();
}

QPoint
Node::inPos() const
{
  return m_in;
}

void
Node::setInPos(const QPoint& p)
{
  m_in = p;
  emit inPosChanged();
}

QPoint
Node::outPos() const
{
  return m_out;
}

void
Node::setOutPos(const QPoint& p)
{
  m_out = p;
  emit outPosChanged();
}

void
Node::setOutput(const bool& o)
{
  m_output = o;
  emit outputChanged();
  emit nodeHaveChanged();
}

bool
Node::output() const
{
  return m_output;
}

void
Node::setBound(const bool& i)
{
  m_bound = i;
  emit boundChanged();
}

bool
Node::bound() const
{
  return m_bound;
}

void
Node::setOpened(const bool& o)
{
  m_opened = o;
  emit openedChanged();
  emit nodeHaveChanged();
}

bool
Node::opened() const
{
  return m_opened;
}

void
Node::setInverted(const bool& i)
{
  m_inverted = i;
  emit invertedChanged();
  emit nodeHaveChanged();
}

bool
Node::inverted() const
{
  return m_inverted;
}

void
Node::setMin(const double& rs)
{
  m_min = rs;
  emit minChanged();
  emit nodeHaveChanged();
}

double
Node::min() const
{
  return m_min;
}

void
Node::setMax(const double& re)
{
  m_max = re;
  emit maxChanged();
  emit nodeHaveChanged();
}

double
Node::max() const
{
  return m_max;
}

void
Node::setFirst(const double& rm)
{
  m_first = rm;

  if (m_bound) {
    m_second = rm;
    emit secondChanged();
  }

  emit firstChanged();
  emit nodeHaveChanged();
}

double
Node::first() const
{
  return m_first;
}

void
Node::setSecond(const double& rm)
{
  m_second = rm;

  if (m_bound) {
    m_first = rm;
    emit firstChanged();
  }
  emit secondChanged();
  emit nodeHaveChanged();
}

double
Node::second() const
{
  return m_second;
}

void
Node::setIp(const QString& i)
{
  m_ip = i;
  emit ipChanged();
  emit nodeHaveChanged();
}

QString
Node::ip() const
{
  return m_ip;
}

QHostAddress
Node::getIp() const
{
  return QHostAddress(m_ip.split(':').first());
}

quint16
Node::getPort() const
{
  return (m_ip.split(':').last()).toInt();
}

qulonglong
Node::id() const
{
  return m_id;
}

void
Node::read(const QJsonObject& json)
{
  if (json.contains("name") && json["name"].isString()) {
    m_name = json["name"].toString();
    emit nameChanged();
  }

  if (json.contains("address") && json["address"].isString()) {
    m_address = json["address"].toString();
    emit addressChanged();
  }

  if (json.contains("ip") && json["ip"].isString()) {
    m_ip = json["ip"].toString();
    emit ipChanged();
  }

  if (json.contains("pos") && json["pos"].isObject()) {
    m_pos = readPoint(json["pos"].toObject());
    emit posChanged();
  }

  if (json.contains("in") && json["in"].isObject()) {
    m_in = readPoint(json["in"].toObject());
    emit inPosChanged();
  }

  if (json.contains("out") && json["out"].isObject()) {
    m_out = readPoint(json["in"].toObject());
    emit outPosChanged();
  }

  if (json.contains("type") && json["type"].isDouble()) {
    m_type = Type(json["type"].toInt());
    emit typeChanged();
  }

  if (json.contains("value") && json["value"].isDouble()) {
    m_value = json["value"].toDouble();
    emit valueChanged();
  }

  if (json.contains("min") && json["min"].isDouble()) {
    m_min = json["min"].toDouble();
    emit minChanged();
  }

  if (json.contains("max") && json["max"].isDouble()) {
    m_max = json["max"].toDouble();
    emit maxChanged();
  }

  if (json.contains("first") && json["first"].isDouble()) {
    m_first = json["first"].toDouble();
    emit firstChanged();
  }

  if (json.contains("second") && json["second"].isDouble()) {
    m_second = json["second"].toDouble();
    emit secondChanged();
  }

  if (json.contains("output") && json["output"].isBool()) {
    m_output = json["output"].toBool();
    emit outputChanged();
  }

  if (json.contains("bound") && json["bound"].isBool()) {
    m_bound = json["bound"].toBool();
    emit boundChanged();
  }

  if (json.contains("opened") && json["opened"].isBool()) {
    m_opened = json["opened"].toBool();
    emit openedChanged();
  }

  if (json.contains("inverted") && json["inverted"].isBool()) {
    m_inverted = json["inverted"].toBool();
    emit invertedChanged();
  }

  if (json.contains("id") && json["id"].isString()) {
    m_id = json["id"].toString().toULongLong();
  }
}

QPoint
Node::readPoint(const QJsonObject& json) const
{
  QPoint point(0, 0);
  if (json.contains("x") && json["x"].isDouble()) {
    point.setX(json["x"].toDouble());
  }

  if (json.contains("y") && json["y"].isDouble()) {
    point.setY(json["y"].toDouble());
  }

  return point;
}

QJsonObject
Node::write() const
{
  QJsonObject json;

  json["name"] = m_name;
  json["address"] = m_address;
  json["ip"] = m_ip;

  json["pos"] = writePoint(m_pos);
  json["in"] = writePoint(m_in);
  json["out"] = writePoint(m_out);

  json["type"] = m_type;

  json["value"] = m_value;
  json["min"] = m_min;
  json["max"] = m_max;
  json["first"] = m_first;
  json["second"] = m_second;

  json["output"] = m_output;
  json["bound"] = m_bound;
  json["opened"] = m_opened;
  json["inverted"] = m_inverted;

  json["id"] = QString::number(m_id);

  return json;
}

QJsonObject
Node::writePoint(const QPoint& point) const
{
  QJsonObject json;
  json["x"] = point.x();
  json["y"] = point.y();
  return json;
}
