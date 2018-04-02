#ifndef NODE_H
#define NODE_H

#include <QObject>
#include <QTimer>
#include <QString>
#include <QPoint>
#include <QDebug>
#include <stdlib.h>

class Node : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Way way READ way WRITE setWay NOTIFY typeChanged)
    Q_PROPERTY(double value	READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool output READ output WRITE setOutput NOTIFY outputChanged)

    Q_PROPERTY(QPoint inPos READ inPos WRITE setInPos NOTIFY inPosChanged)
    Q_PROPERTY(QPoint outPos READ outPos WRITE setOutPos NOTIFY outPosChanged)

public:
    explicit Node(QObject *parent = nullptr);

    enum Way {
        None = 0,
        In = 1,
        Out = 2,
        Both = 11
    };

    Q_ENUM(Way)

    QPoint inPos() const;
    void setInPos(const QPoint& p);

    QPoint outPos() const;
    void setOutPos(const QPoint& p);

    void setWay(const Way& t);
    Way way() const;

    void setValue(const double& v);
    double value() const;

    void setName(const QString& n);
    QString name() const;

    void setOutput(const bool& o);
    bool output() const;

private:
    QPoint m_in;
    QPoint m_out;
    Way m_type = None;
    double m_value = 0.0;
    QString m_name = "Name";
    bool m_output = false;
    QTimer* timer;

signals:
    void typeChanged();
    void valueChanged();
    void nameChanged();
    void connectionsMightHaveChanged();
    void inPosChanged();
    void outPosChanged();
    void outputChanged();

private slots:
    void randValue();
};

#endif // NODE_H
