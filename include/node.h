#pragma once

#include <QObject>
#include <QTimer>
#include <QDateTime>
#include <QString>
#include <QPoint>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <stdlib.h>
#include <QHostAddress>
#include <QJsonObject>

#include "osc/reader/OscMessage.h"
#include "node.h"

class Node : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Type type READ type WRITE setType NOTIFY typeChanged)

    Q_PROPERTY(double value	READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(bool output READ output WRITE setOutput NOTIFY outputChanged)

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(QString ip READ ip WRITE setIp NOTIFY ipChanged)

    Q_PROPERTY(bool bound READ bound WRITE setBound NOTIFY boundChanged)
    Q_PROPERTY(bool opened READ opened WRITE setOpened NOTIFY openedChanged)
    Q_PROPERTY(bool inverted READ inverted WRITE setInverted NOTIFY invertedChanged)

    Q_PROPERTY(QPoint pos READ pos WRITE setPos NOTIFY posChanged)
    Q_PROPERTY(QPoint inPos READ inPos WRITE setInPos NOTIFY inPosChanged)
    Q_PROPERTY(QPoint outPos READ outPos WRITE setOutPos NOTIFY outPosChanged)

    Q_PROPERTY(double min READ min WRITE setMin NOTIFY minChanged)
    Q_PROPERTY(double max READ max WRITE setMax NOTIFY maxChanged)
    Q_PROPERTY(double first READ first WRITE setFirst NOTIFY firstChanged)
    Q_PROPERTY(double second READ second WRITE setSecond NOTIFY secondChanged)

public:
    explicit Node(QObject *parent = nullptr);

    enum Type {
        Input = 0,
        Output = 1,
        OrGate = 10,
        AndGate = 11
    };

    Q_ENUM(Type)

    QPoint pos() const;
    void setPos(const QPoint& p);

    QPoint inPos() const;
    void setInPos(const QPoint& p);

    QPoint outPos() const;
    void setOutPos(const QPoint& p);

    void setType(const Type& t);
    Type type() const;

    void setValue(const double& v);
    double value() const;

    void setName(const QString& n);
    QString name() const;

    void setAddress(const QString& i);
    QString address() const;

    void setOutput(const bool& o);
    bool output() const;

    void setBound(const bool& i);
    bool bound() const;

    void setOpened(const bool& o);
    bool opened() const;

    void setInverted(const bool& i);
    bool inverted() const;

    void setMin(const double& rs);
    double min() const;

    void setMax(const double& re);
    double max() const;

    void setFirst(const double& rm);
    double first() const;

    void setSecond(const double& rm);
    double second() const;

    void setIp(const QString& i);
    QString ip() const;

    QHostAddress getIp() const;
    quint16 getPort() const;

    qulonglong id() const;

    void read(const QJsonObject& json);
    QJsonObject write() const;

    QPoint readPoint(const QJsonObject&) const;
    QJsonObject writePoint(const QPoint&) const;

private:
    QString m_name = "Name";
    QString m_address = "/home/default";
    QString m_ip = "127.0.0.1:8888";

    QPoint m_pos;
    QPoint m_in;
    QPoint m_out;

    Type m_type = Node::Input;

    double m_value = 0.0;
    double m_min = 0.0;
    double m_max = 100.0;
    double m_first = 25.0;
    double m_second = 75.0;


    bool m_output = true;
    bool m_bound = false;
    bool m_opened = true;
    bool m_inverted = false;

    qulonglong m_id;
signals:
// basic
    void typeChanged();
    void nameChanged();
    void addressChanged();
    void ipChanged();
    void connectionsHaveChanged();
    void posChanged();
    void inPosChanged();
    void outPosChanged();
    void outputChanged();
    void boundChanged();
    void openedChanged();
    void invertedChanged();
    void messageReady(Node*);
    void valueChanged();
    void nodeHaveChanged();

// input
    void minChanged();
    void maxChanged();
    void firstChanged();
    void secondChanged();

// output
    void methodChanged();
    void conditionOverriden();
};
