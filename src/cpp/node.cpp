#include "node.h"

Node::Node(QObject *parent) : QObject(parent)
{
    timer = new QTimer{this};

    if(m_type == Out) {
        connect(timer, SIGNAL(timeout()), this, SLOT(randValue()));
        timer->start(1000);
    }
}

void Node::setWay(const Way &t) {

    if(t == Out && t != m_type) {
        connect(timer, SIGNAL(timeout()), this, SLOT(randValue()));
        timer->start(1000);
    } else if (t != Out) {
        timer->stop();
    }

    m_type = t;
    emit typeChanged();
}

Node::Way Node::way() const {
    return m_type;
}

void Node::setValue(const double &v) {
    m_value = v;
    emit valueChanged();
}

double Node::value() const {
    return m_value;
}

void Node::randValue() {
    setValue(rand() % 100);
}

QString Node::name() const {
    return m_name;
}

void Node::setName(const QString &n) {
    m_name = n;
    emit nameChanged();
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
