#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "neobasicnodedata.h"
#include "node.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    Node* n = new Node();

    qDebug() << n->value() << '\n';
    qDebug() << n->type() << '\n';

    qmlRegisterType<NeonodeComponentData>("Neo.nodeComponent.Data", 1, 0, "NeonodeComponentData");
    qmlRegisterType<Node>("Neo.Node", 1, 0, "Node");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
