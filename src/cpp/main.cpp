#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlContext>
#include <QtSql>

#include "inputnode.h"
#include "connection.h"
#include "room.h"

void addComponent(QSqlQuery& q, const QString& key, const qint64& ltime, const QString& lwrite, const qint8& seen) {
    q.addBindValue(key);
    q.addBindValue(ltime);
    q.addBindValue(lwrite);
    q.addBindValue(seen);
    q.exec();
}

QSqlError dbTest() {

    if (!QSqlDatabase::drivers().contains("QSQLITE")) {
        qDebug() << "No SQLITE driver.";
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("APOCALYPSE");

    if (!db.open()) {
        return db.lastError();
    }

    QStringList tables = db.tables();
    if (tables.contains("components", Qt::CaseInsensitive)) {
        return QSqlError();
    }

    QSqlQuery q;
    if (!q.exec(QLatin1String("create table components(id varchar primary key, time integer, value real, seen integer)"))) {
        return q.lastError();
    }

    if (!q.prepare(QLatin1String("insert into components(id, time, value, seen) values(?, ?, ?, ?)"))) {
        return q.lastError();
    }

    addComponent(q,
                 QLatin1String("FIRST"),
                 QDateTime::currentMSecsSinceEpoch(),
                 QString::number(14.3),
                 false);

    addComponent(q,
                 QLatin1String("SECOND"),
                 QDateTime::currentMSecsSinceEpoch(),
                 QString::number(34.54),
                 false);

    addComponent(q,
                 QLatin1String("DEFAULT"),
                 QDateTime::currentMSecsSinceEpoch(),
                 QString::number(389.76),
                 false);

    return QSqlError();
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QFile f("APOCALYPSE");
    f.remove();
    QSqlError err = dbTest();
    if (err.type() != QSqlError::NoError) {
        qDebug() << "DB Error: " << err.text();
    }

    qmlRegisterType<Node>("Neo.Node.Input", 1, 0, "InputNode");
    qmlRegisterType<Room>("Neo.Room", 1, 0, "Room");
    qmlRegisterType<Connection>("Neo.Connection", 1, 0, "Connection");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
