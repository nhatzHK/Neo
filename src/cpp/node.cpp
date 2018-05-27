#include "node.h"

Node::Node(QObject *parent) : QObject(parent)
{
    connect (this, &Node::conditionOverriden, [=] () {
        emit messageReady (this);
    });
    connect (this, &Node::outputChanged, [=] () {
        if(type () == Node::Output && output ()) {
            emit messageReady (this);
        }
    });
}

void Node::setType(const Type &t) {
    m_type = t;
    emit typeChanged();
}

Node::Type Node::type() const {
    return m_type;
}

void Node::setValue(const double &v) {
    m_value = v;
    emit valueChanged();
}

double Node::value() const {
    return m_value;
}

QString Node::name() const {
    return m_name;
}

void Node::setName(const QString &n) {
    m_name = n;
    emit nameChanged();
}

QString Node::address() const {
    return m_address;
}

void Node::setAddress(const QString &i) {
    m_address = i;
    emit addressChanged();
}

QPoint Node::pos () const {
    return m_pos;
}

void Node::setPos (const QPoint &p) {
    m_pos = p;
    emit posChanged ();
}

QPoint Node::inPos() const {
    return m_in;
}

void Node::setInPos(const QPoint &p) {
    m_in = p;
    emit inPosChanged();
}

QPoint Node::outPos() const {
    return m_out;
}

void Node::setOutPos(const QPoint &p) {
    m_out = p;
    emit outPosChanged();
}

void Node::setOutput(const bool& o) {
    m_output = o;
    emit outputChanged();
}

bool Node::output() const {
    return m_output;
}

void Node::setBound (const bool& i) {
    m_bound = i;
    emit boundChanged ();
}

bool Node::bound () const {
    return m_bound;
}

void Node::setOpened (const bool &o) {
    m_opened = o;
    emit openedChanged ();
}

bool Node::opened () const {
    return m_opened;
}

void Node::setInverted (const bool &i) {
    m_inverted = i;
    emit invertedChanged ();
}

bool Node::inverted () const {
    return m_inverted;
}

void Node::setMin (const double &rs) {
    m_min = rs;
    emit minChanged();
}

double Node::min () const {
    return m_min;
}

void Node::setMax (const double &re) {
    m_max = re;
    emit maxChanged();
}

double Node::max () const {
    return m_max;
}

void Node::setFirst (const double &rm) {
    m_first = rm;

    if(m_bound) {
        m_second = rm;
        emit secondChanged ();
    }

    emit firstChanged ();
}

double Node::first () const {
    return m_first;
}

void Node::setSecond (const double &rm) {
    m_second = rm;

    if(m_bound) {
        m_first = rm;
        emit firstChanged ();
    }
    emit secondChanged ();
}

double Node::second () const {
    return m_second;
}

void Node::setIp (const QString &i) {
    m_ip = i;
    emit ipChanged();
}

QString Node::ip () const {
    return m_ip;
}

QHostAddress Node::getIp () const {
    return QHostAddress(m_ip.split (':').first ());
}

quint16 Node::getPort () const {
    return (m_ip.split (':').last ()).toInt();
}
