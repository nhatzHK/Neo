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
#include "node.h"

class Node : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Type type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(double value	READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString rowId READ rowId WRITE setRowId NOTIFY rowIdChanged)
    Q_PROPERTY(bool output READ output WRITE setOutput NOTIFY outputChanged)
    Q_PROPERTY(bool bound READ bound WRITE setBound NOTIFY boundChanged)
    Q_PROPERTY(bool opened READ opened WRITE setOpened NOTIFY openedChanged)
    Q_PROPERTY(bool inverted READ inverted WRITE setInverted NOTIFY invertedChanged)

    Q_PROPERTY(QPoint inPos READ inPos WRITE setInPos NOTIFY inPosChanged)
    Q_PROPERTY(QPoint outPos READ outPos WRITE setOutPos NOTIFY outPosChanged)

    Q_PROPERTY(double min READ min WRITE setMin NOTIFY minChanged)
    Q_PROPERTY(double max READ max WRITE setMax NOTIFY maxChanged)
    Q_PROPERTY(double first READ first WRITE setFirst NOTIFY firstChanged)
    Q_PROPERTY(double second READ second WRITE setSecond NOTIFY secondChanged)

    Q_PROPERTY(QString method READ method WRITE setMethod NOTIFY methodChanged)
    Q_PROPERTY(QString args READ args WRITE setArgs NOTIFY argsChanged)

public:
    explicit Node(QObject *parent = nullptr);

    enum Type {
        Input = 0,
        Output = 1,
        OrGate = 10,
        AndGate = 11
    };

    Q_ENUM(Type)

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

    void setRowId(const QString& i);
    QString rowId() const;

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

    void setArgs(const QString& a);
    QString args() const;

    void setMethod(const QString& m);
    QString method() const;

private:
    void updateId();

    QPoint m_in;
    QPoint m_out;

    Type m_type = Node::Input;

    double m_value = 0.0;

    double m_min = 0.0;
    double m_max = 100.0;
    double m_first = 25.0;
    double m_second = 75.0;

    QString m_name = "Name";

    QString m_rowId = "DEFAULT";

    QString m_method = "default";
    QString m_args = "1, 2, 3";

    bool m_output = true;
    bool m_bound = false;
    bool m_opened = true;
    bool m_inverted = false;

    QTimer* m_dbReadTimer;
    QTimer* m_dbWriteTimer;

    QSqlQuery mq_readLastWrite;
    QSqlQuery mq_setAsRead;
    QSqlQuery mq_sendMessage;

signals:
    void typeChanged();
    void valueChanged();
    void nameChanged();
    void rowIdChanged();
    void connectionsHaveChanged();
    void inPosChanged();
    void outPosChanged();
    void outputChanged();
    void boundChanged();
    void openedChanged();
    void invertedChanged();
    void minChanged();
    void maxChanged();
    void firstChanged();
    void secondChanged();
    void methodChanged();
    void argsChanged();
    void conditionOverriden();
    void messageSent();

private slots:
    void psl_updateValue();
    void psl_sendMessage();
};
