#ifndef NEOnodeComponentDATA_H
#define NEOnodeComponentDATA_H

#include <QObject>
#include <QTimer>
#include <cstdlib>

class NeonodeComponentData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qint64 data READ data WRITE setData NOTIFY dataChanged)

public:
    explicit NeonodeComponentData(QObject *parent = nullptr);

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

#endif // NEOnodeComponentDATA_H
