#include "neobasicnodedata.h"

NeoBasicNodeData::NeoBasicNodeData(QObject *parent) : QObject(parent)
{
    timer = new QTimer{this};
    connect(timer, SIGNAL(timeout()), this, SLOT(incData()));
    timer->start(1000);
}

qint64 NeoBasicNodeData::data() {
    return m_data;
}

void NeoBasicNodeData::setData(const qint64 &data) {
    m_data = data;
    emit dataChanged();
}

void NeoBasicNodeData::incData() {
     setData(rand() % 10);
}
