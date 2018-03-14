#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "neobasicnodedata.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<NeoBasicNodeData>("Neo.BasicNode.Data", 1, 0, "NeoBasicNodeData");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
