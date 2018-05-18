#include "node.h"

Node::Node(QObject *parent) : QObject(parent)
{
    m_dbReadTimer = new QTimer{this};

    connect(m_dbReadTimer, &QTimer::timeout, this, &Node::psl_updateValue);
    connect (this, &Node::rowIdChanged, this, &Node::psl_updateValue);
    connect (this, &Node::conditionOverriden, this, &Node::psl_sendMessage);
    connect (this, &Node::outputChanged, [=] () {
        if(type () == Node::Output && output ()) {
            psl_sendMessage ();
        }
    });

    m_dbReadTimer->start(1000);

    if(!mq_readLastWrite.prepare("SELECT args, time FROM messages "
                                    "WHERE time = (SELECT max(time) FROM messages "
                                        "WHERE recipient = :recipient AND method = \"SET\")")) {
        qDebug() << "DB PREPARE ERROR: (mq_readLastWrite) (node - ctor) " << mq_readLastWrite.lastError().text() << '\n';
    }

    if(!mq_setAsRead.prepare ("UPDATE messages SET seen = 1 WHERE id = :id")) {
        qDebug() << "DB PREPARE ERROR: (mq_setAsRead) (node - ctor) " << mq_setAsRead.lastError ().text () << '\n';
    }

    if(!mq_sendMessage.prepare ("INSERT INTO "
                                  "messages(recipient, method, args, time)"
                                  "VALUES(?, ?, ?, ?)")) {
        qDebug() << "DB PREPARE ERROR: (mq_sendMessage) (node - ctor) " << mq_sendMessage.lastError ().text () << '\n';
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

void Node::psl_updateValue() {
    mq_readLastWrite.bindValue (":recipient", m_rowId);
    mq_readLastWrite.exec();

    if(mq_readLastWrite.first()) {
        auto v = mq_readLastWrite.value(0).toDouble();
        setValue(v);
    }

    mq_readLastWrite.finish ();
}

void Node::psl_sendMessage() {
    mq_sendMessage.addBindValue (m_rowId);
    mq_sendMessage.addBindValue (m_method);
    mq_sendMessage.addBindValue (m_args);
    mq_sendMessage.addBindValue (QDateTime::currentMSecsSinceEpoch ());
    if (!mq_sendMessage.exec ()) {
        qDebug() << "DB SEND ERROR: (psl_sendMessage-" << m_name << ") " << mq_sendMessage.lastError ().text ();
    }

    mq_sendMessage.finish ();
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

void Node::setMethod (const QString &m) {
    m_method = m;
    emit methodChanged();
}

QString Node::method () const {
    return m_method;
}

QString Node::args () const {
    return m_args;
}

void Node::setArgs (const QString &a) {
    m_args = a;
    emit argsChanged ();
}
