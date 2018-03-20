#include "node.h"

Node::Node(QObject *parent) : QObject(parent)
{
    timer = new QTimer{this};

    if(m_type == Out) {
        connect(timer, SIGNAL(timeout()), this, SLOT(randValue()));
        timer->start(1000);
    }
}

void Node::setType(const Type &t) {

    if(t == Out && t != m_type) {
        connect(timer, SIGNAL(timeout()), this, SLOT(randValue()));
        timer->start(1000);
    } else if (t != Out) {
        timer->stop();
    }

    m_type = t;
    emit typeChanged();
}

Node::Type Node::type() {
    return m_type;
}

void Node::setValue(const double &v) {
    m_value = v;
    emit valueChanged();
}

double Node::value() {
    return m_value;
}

void Node::randValue() {
    setValue(rand() % 100);
}

QString Node::name() {
    return m_name;
}

void Node::setName(const QString &n) {
    m_name = n;
    emit nameChanged();
}
