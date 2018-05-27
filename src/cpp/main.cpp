#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "connection.h"
#include "room.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

//    int a = 0;
//    int b = 0;
//    int* aa = &a;
//    int* bb = &b;

//    qDebug() << OSCPatternMatching::osc_match("hello", "hello", aa, bb) << ' ' << a << ' ' << b << '\n';

//    delete m;

    qmlRegisterType<Node>("Neo.Node", 1, 0, "Node");
    qmlRegisterType<Room>("Neo.Room", 1, 0, "Room");
    qmlRegisterType<Connection>("Neo.Connection", 1, 0, "Connection");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    auto win = engine.rootObjects ().at (0);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
