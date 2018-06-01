#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "connection.h"
#include "room.h"

int
main(int argc, char* argv[])
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

  QGuiApplication app(argc, argv);

  qmlRegisterType<Node>("Neo.Node", 1, 0, "Node");
  qmlRegisterType<Room>("Neo.Room", 1, 0, "Room");
  qmlRegisterType<Connection>("Neo.Connection", 1, 0, "Connection");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

  auto win = engine.rootObjects().at(0);

  if (engine.rootObjects().isEmpty())
    return -1;

  return app.exec();
}
