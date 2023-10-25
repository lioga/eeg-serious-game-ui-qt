#ifndef BLUETOOTHLIST_H
#define BLUETOOTHLIST_H

#include <QObject>
#include <QVector>

class HTTPHelper;
class UDPHelper;


struct BluetoothItem
{
    bool done;
    QString description;

};

class BluetoothList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString serverMessage READ serverMessage NOTIFY serverMessageChanged)
    Q_PROPERTY(bool getServerStatus READ getServerStatus NOTIFY isServerAwakeChanged)

public:
    explicit BluetoothList(QObject *parent = nullptr);

    QVector<BluetoothItem> items() const;
    bool setItemAt(int index, const BluetoothItem &item);
    Q_INVOKABLE void isServerAwake();
    Q_INVOKABLE void scanBluetoothDevices();
    Q_INVOKABLE void turnONBluetooth();
    Q_INVOKABLE void turnOFFBluetooth();
    Q_INVOKABLE void connectBluetooth();
    Q_INVOKABLE void disconnectBluetooth();
    Q_INVOKABLE void startUDPStream();
    Q_INVOKABLE void stopUDPStream();
    Q_INVOKABLE QString serverMessage() const;
    Q_INVOKABLE bool getIsScanFinished() const;
    Q_INVOKABLE bool getIsConnectFinished() const;
    Q_INVOKABLE bool getServerStatus() const;
    Q_INVOKABLE UDPHelper* returnUDPHelper();


    Q_INVOKABLE void removeAllItems();

signals:
    void preItemAppended();
    void postItemAppended();

    void preItemRemoved(int index);
    void postItemRemoved();

    void serverMessageChanged();

    void isScanFinishedChanged();
    void isServerAwakeChanged();
    void isConnectFinishedChanged();

public slots:
    void appendItem();
    void removeCompletedItems();
    void handleServerStatus(const QString& answer);
private slots:
    void handleScanFinished(const QString& answer);
    void handleBluetoothOnOffFinished(const QString& answer);
    void handleConnectFinished(const QString& answer);
    void handleDisconnectFinished(const QString& answer);
    void handleUDPStreamStarted(const QString& answer);
    void handleUDPStreamStopped(const QString& answer);

private:
    void displayServerMessage(const QString &value);
    QVector<BluetoothItem> mItems;
    HTTPHelper *httpHelper;
    UDPHelper *udpHelper;
    QString mmessageString;
    QString mipAdress;
    bool isScanFinished = true;
    bool isConnectFinished = true;
    bool m_isServerAwake = false;

};

#endif // BLUETOOTHLIST_H
