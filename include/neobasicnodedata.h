#ifndef NEOBASICNODEDATA_H
#define NEOBASICNODEDATA_H

#include <QObject>
#include <QTimer>
#include <cstdlib>

class NeoBasicNodeData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qint64 data READ data WRITE setData NOTIFY dataChanged)

public:
    explicit NeoBasicNodeData(QObject *parent = nullptr);

    qint64 data();
    void setData(const qint64 &data);
signals:
    void dataChanged();

private slots:
    void incData();
private:
    qint64 m_data = 0;
    QTimer* timer;
};

#endif // NEOBASICNODEDATA_H
