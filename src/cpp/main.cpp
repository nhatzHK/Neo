#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlContext>
#include <QtSql>
#include <QPair>
#include <QVariant>

#include "connection.h"
#include "room.h"

QSqlError openDatabase(QString filename) {

    if (!QSqlDatabase::drivers().contains("QSQLITE")) {
        qDebug() << "No SQLITE driver.";
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(filename);

    if (!db.open()) {
        return db.lastError();
    }

    return QSqlError();
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QString sqliteFilePath("/home/errpell/Code/Ressources/Neo/DB/APOCALYPSE");
    QSqlError err = openDatabase (sqliteFilePath);
    if (err.type () != QSqlError::NoError) {
        qDebug() << "DB OPEN ERROR (main): " << err.text ();
    }

    qmlRegisterType<Node>("Neo.Node", 1, 0, "Node");
    qmlRegisterType<Room>("Neo.Room", 1, 0, "Room");
    qmlRegisterType<Connection>("Neo.Connection", 1, 0, "Connection");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
