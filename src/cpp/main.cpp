#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlContext>

#include "node.h"
#include "connection.h"
#include "room.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

//    Room r;
//    Node* n1 = new Node();
//    n1->setName("In Node");
//    Node* n2 = new Node();
//    n2->setName("Out Node");

//    Connection* c = new Connection();
//    c->setIn(n1);
//    c->setOut(n2);
//    r.addConnection(c);
//    for(int i = 0; i < 10; ++i) {
//        if(r.connected(n2, n1, Node::In)) {
//            qDebug() << "In yes\n";
//        } else if(r.connected(n2, n1, Node::Out)) {
//            qDebug() << "Out yes\n";
//        } else {
//            qDebug() << "Uh oh\n";
//        }
//    }

    qmlRegisterType<Node>("Neo.Node", 1, 0, "Node");
    qmlRegisterType<Room>("Neo.Room", 1, 0, "Room");
    qmlRegisterType<Connection>("Neo.Connection", 1, 0, "Connection");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
