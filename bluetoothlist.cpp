#include "bluetoothlist.h"
#include "httphelper.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include <QJsonArray>
#include <QDebug>
#include "udphelper.h"

//all the main functionality, communicates with QML
BluetoothList::BluetoothList(QObject *parent) : QObject(parent) //constr of the bluetooth data list
{
    httpHelper = new HTTPHelper(this);
    udpHelper = new UDPHelper(this);
    mipAdress = "http://127.0.0.1:8080"; //HTTP server ip adress
}

Q_INVOKABLE void BluetoothList::isServerAwake(){ //checks if server awake
    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleServerStatus(QString)));
    httpHelper->GET(mipAdress + "/amiawake");
}

void BluetoothList::handleServerStatus(const QString& answer) //Handles if server awake notifies qml
{
    if(answer != "ERROR")
        m_isServerAwake = true;
    else if (answer == "ERROR")
        m_isServerAwake = false;
    qDebug() << answer;
    emit isServerAwakeChanged();
    disconnect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleServerStatus(QString)));
}

bool BluetoothList::getServerStatus() const
{
    return m_isServerAwake;
}

Q_INVOKABLE void BluetoothList::scanBluetoothDevices() //bluetooth scanner, triggered by scan button, uses HTTPHelper class
{                                                      // gets value adresses to the /scan
    isScanFinished = false;
    emit isScanFinishedChanged();

    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleScanFinished(QString)));
    qDebug() << "scan clicked";
    httpHelper->GET(mipAdress + "/scan");
}

void BluetoothList::handleScanFinished(const QString& answer) //When the scan get request finished, parses json data
{                                                             // and appends the items to the list
    QString scanMessage = "{\"mesaj\":\"Tarama Bitti\"}";
    displayServerMessage(scanMessage);
    QJsonDocument jsonResponse = QJsonDocument::fromJson(answer.toUtf8());
    QJsonObject jsonObject = jsonResponse.object(); // Get the JSON object
    QJsonArray jsonArray = jsonObject[QString("cihazlar")].toArray();

    for (int i = 0; i < mItems.size(); ) { //firstly cleans the items

            emit preItemRemoved(i);

            mItems.removeAt(i);

            emit postItemRemoved();
        }

    foreach (const QJsonValue &value, jsonArray) {  //adds new items
        emit preItemAppended();

        QJsonObject obj = value.toObject();
        mItems.append({ false, obj.value("MAC").toString() + "         " + obj.value("isim").toString()});

        emit postItemAppended();
    }
    isScanFinished = true;
    emit isScanFinishedChanged();

    disconnect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleScanFinished(QString)));
}

Q_INVOKABLE void BluetoothList::turnONBluetooth() //bluetooth turn on, triggered by turn on button, uses HTTPHelper class
{
    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleBluetoothOnOffFinished(QString)));
    qDebug() << "turn on bluetooth clicked";

    httpHelper->GET(mipAdress + "/on");

}

Q_INVOKABLE void BluetoothList::turnOFFBluetooth() //bluetooth turn on, triggered by turn on button, uses HTTPHelper class
{
    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleBluetoothOnOffFinished(QString)));
    qDebug() << "turn off bluetooth clicked";
    httpHelper->GET(mipAdress + "/off");
}

void BluetoothList::handleBluetoothOnOffFinished(const QString& answer) //Handles blueetooth turn on/off request finished
{
    disconnect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleBluetoothOnOffFinished(QString)));
    qDebug()<<"handlebluetoothonoff";
    qDebug() << answer;
    displayServerMessage(answer);
}

Q_INVOKABLE void BluetoothList::connectBluetooth() //bluetooth connect
{
    isConnectFinished = false;

    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleConnectFinished(QString)));
    qDebug() << "connect bluetooth clicked";
    int i = 0;
    for (i = 0; i < mItems.count(); ++i) {

        if (mItems[i].done){
            qDebug() << mItems[i].description;
            QString allDescripton = mItems[i].description;
            QStringList descriptionList = allDescripton.split(" ");
            httpHelper->GET(mipAdress + "/connect?mac=" + descriptionList[0]);
        }
    }

}

void BluetoothList::handleConnectFinished(const QString& answer){
    displayServerMessage(answer);
    disconnect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleConnectFinished(QString)));

    isConnectFinished = true;
}

Q_INVOKABLE void BluetoothList::disconnectBluetooth() //bluetooth disconnect
{
    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleDisconnectFinished(QString)));
    qDebug() << "disconnect bluetooth clicked";

    int i = 0;
    for (i = 0; i < mItems.count(); ++i) {
        if (mItems[i].done){
            qDebug() << mItems[i].description;
            QString allDescripton = mItems[i].description;
            QStringList descriptionList = allDescripton.split(" ");
            qDebug()<<descriptionList[0];
            httpHelper->GET(mipAdress +"/disconnect?mac=" + descriptionList[0]);
        }
    }
}

void BluetoothList::handleDisconnectFinished(const QString& answer){
    qDebug() << answer;
    displayServerMessage(answer);
    disconnect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleDisconnectFinished(QString)));
}

Q_INVOKABLE void BluetoothList::startUDPStream(){
    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleUDPStreamStarted(QString)));
    httpHelper->GET(mipAdress + "/stream");
    qDebug() << "start request UDPstream";
}

void BluetoothList::handleUDPStreamStarted(const QString& answer){
    disconnect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleUDPStreamStarted(QString)));
    udpHelper->UDPStreamStarted();
}

Q_INVOKABLE void BluetoothList::stopUDPStream(){
    connect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleUDPStreamStopped(QString)));
    httpHelper->GET(mipAdress + "/stream_stop");
    qDebug() << "stop request UDPstream";
}
void BluetoothList::handleUDPStreamStopped(const QString& answer){
    disconnect(httpHelper, SIGNAL(requestFinished(QString)), this, SLOT(handleUDPStreamStopped(QString)));
    udpHelper->UDPStreamStopped();
}

QString BluetoothList::serverMessage() const
{
    return mmessageString;
}

void BluetoothList::displayServerMessage(const QString &value){ //displayes "mesaj" key's value in the text box in qml
    if (value != mmessageString) {

        QJsonDocument jsonResponse = QJsonDocument::fromJson(value.toUtf8());
        QJsonObject jsonObject = jsonResponse.object(); // Get the JSON object
        QVariantMap variantMap = jsonObject.toVariantMap();

        mmessageString = variantMap["mesaj"].toString();
        emit serverMessageChanged();
    }
}

Q_INVOKABLE bool BluetoothList::getIsScanFinished() const{ //while it is false, client can't send amiawake request

    return isScanFinished;
}

Q_INVOKABLE bool BluetoothList::getIsConnectFinished() const{ //while it is false, client can't send amiawake request

    return isConnectFinished;
}

QVector<BluetoothItem> BluetoothList::items() const
{
    return mItems;
}

bool BluetoothList::setItemAt(int index, const BluetoothItem &item)
{
    if (index < 0 || index >= mItems.size())
        return false;

    const BluetoothItem &oldItem = mItems.at(index);
    if (item.done == oldItem.done && item.description == oldItem.description)
        return false;
    mItems[index] = item;

    return true;
}
Q_INVOKABLE void BluetoothList::removeAllItems()
{
    for (int i = 0; i < mItems.size(); ) {
        emit preItemRemoved(i);

        mItems.removeAt(i);

        emit postItemRemoved();
    }
}

Q_INVOKABLE UDPHelper* BluetoothList::returnUDPHelper(){
    return udpHelper;
}



//////code below will not be used, stays as example for now, delete later
void BluetoothList::appendItem()
{
    emit preItemAppended();

    BluetoothItem item;
    item.done = false;
    mItems.append(item);

    emit postItemAppended();
}

void BluetoothList::removeCompletedItems()
{
    for (int i = 0; i < mItems.size(); ) {
        if (mItems.at(i).done) {
            emit preItemRemoved(i);

            mItems.removeAt(i);

            emit postItemRemoved();
        } else {
            ++i;
        }
    }
}

