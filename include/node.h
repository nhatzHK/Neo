#pragma once

#include <QObject>
#include <QTimer>
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

    void setMin(const double& rs);
    double min() const;

    void setMax(const double& re);
    double max() const;

    void setFirst(const double& rm);
    double first() const;

    void setSecond(const double& rm);
    double second() const;

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

    bool m_output = true;

    QTimer* timer;
    QSqlQuery mq_updateId;
    QSqlQuery mq_readValue;

signals:
    void typeChanged();
    void valueChanged();
    void nameChanged();
    void rowIdChanged();
    void connectionsHaveChanged();
    void inPosChanged();
    void outPosChanged();
    void outputChanged();
    void minChanged();
    void maxChanged();
    void firstChanged();
    void secondChanged();

private slots:
    void psl_readValue();
};
