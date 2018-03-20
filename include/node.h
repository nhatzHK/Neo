#ifndef NODE_H
#define NODE_H

#include <QObject>
#include <QTimer>
#include <QString>
#include <cstdlib>

class Node : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Type type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(double value	READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
public:
    explicit Node(QObject *parent = nullptr);
    static Node* createNode() {
        Node* n = new Node();
        return n;
    }

    enum Type {
        None = 0,
        In = 1,
        Out = 2,
        Both = 11
    };
    Q_ENUM(Type)

    void setType(const Type& t);
    Type type();

    void setValue(const double& v);
    double value();

    void setName(const QString& n);
    QString name();

private:
    Type m_type = None;
    double m_value = 0.0;
    QString m_name = "Name";
    QTimer* timer;

signals:
    void typeChanged();
    void valueChanged();
    void nameChanged();

private slots:
    void randValue();
};

#endif // NODE_H
