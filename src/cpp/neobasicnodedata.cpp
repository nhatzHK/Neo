#include "neobasicnodedata.h"

NeoBasicNodeData::NeoBasicNodeData(QObject *parent) : QObject(parent)
{

}

qint64 NeoBasicNodeData::data() {
    return m_data;
}

void NeoBasicNodeData::setData(const qint64 &data) {
    m_data = data;
    emit dataChanged();
}
