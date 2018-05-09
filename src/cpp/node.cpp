#include "node.h"

Node::Node(QObject *parent) : QObject(parent)
{
    timer = new QTimer{this};

    connect(timer, SIGNAL(timeout()), this, SLOT(psl_readValue()));
    connect (this, SIGNAL(rowIdChanged()), this, SLOT(psl_readValue()));
    timer->start(1000);

    if(!mq_readValue.prepare("SELECT value FROM components WHERE id = :id")) {
        qDebug() << "DB PREPARE ERROR: (node - ctor) " << mq_readValue.lastError().text() << '\n';
    }

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

void Node::psl_readValue() {
    mq_readValue.bindValue (":id", m_rowId);
    mq_readValue.exec();
    mq_readValue.first();
    auto v = mq_readValue.value(0).toDouble();
    setValue(v);
    while(mq_readValue.next()) {
        qDebug() << mq_readValue.value (0).toString ();
    }
}

QString Node::name() const {
    return m_name;
}

void Node::setName(const QString &n) {
    m_name = n;
    emit nameChanged();
}

QString Node::rowId() const {
    return m_rowId;
}

void Node::setRowId(const QString &i) {
    m_rowId = i;
    emit rowIdChanged();
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
    emit firstChanged ();
}

double Node::first () const {
    return m_first;
}

void Node::setSecond (const double &rm) {
    m_second = rm;
    emit secondChanged ();
}

double Node::second () const {
    return m_second;
}
