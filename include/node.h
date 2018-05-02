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

private:
    void updateId();

    QPoint m_in;
    QPoint m_out;
    Type m_type = Node::Input;
    double m_value = 0.0;
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

private slots:
    void psl_readValue();
};
