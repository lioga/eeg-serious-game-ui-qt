#include "listviewmodel.h"
#include "bluetoothlist.h"
#include "udphelper.h"
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>


int main(int argc, char *argv[]) {

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<ListViewModel>("ListViewModel", 1, 0, "ListViewModel");

    BluetoothList bluetoothList;

    //all the http request connected to the qml
    engine.rootContext()->setContextProperty("bluetoothList", &bluetoothList);

    //just for udp data stream
    engine.rootContext()->setContextProperty("mindwaveData", bluetoothList.returnUDPHelper());

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    QObject::connect(&engine, &QQmlEngine::quit , &app, &QCoreApplication::quit, Qt::QueuedConnection);

    return app.exec();
}
