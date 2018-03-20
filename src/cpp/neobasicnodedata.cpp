#include "neobasicnodedata.h"

NeonodeComponentData::NeonodeComponentData(QObject *parent) : QObject(parent)
{
    timer = new QTimer{this};
    connect(timer, SIGNAL(timeout()), this, SLOT(incData()));
    timer->start(1000);
}

qint64 NeonodeComponentData::data() {
    return m_data;
}

void NeonodeComponentData::setData(const qint64 &data) {
    m_data = data;
    emit dataChanged();
}

void NeonodeComponentData::incData() {
     setData(rand() % 10);
}
