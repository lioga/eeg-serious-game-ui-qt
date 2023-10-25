#ifndef UDPHELPER_H
#define UDPHELPER_H
#include <QUdpSocket>


class UDPHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int readAttention READ readAttention NOTIFY attentionChangedP1)
    Q_PROPERTY(int readAttention READ readAttention NOTIFY attentionChangedP2)
    Q_PROPERTY(int readSignalQuality READ readSignalQuality NOTIFY signalQualityChangedP1)
    Q_PROPERTY(int readSignalQuality READ readSignalQuality NOTIFY signalQualityChangedP2)
public:
    explicit UDPHelper(QObject *parent = 0);


private:
    QUdpSocket *socket;
    quint8 *recievedBytes;

    int readAttention() const;
    QPoint readChartAttention();
    int readSignalQuality() const;


signals:
    void attentionChangedP1();
    void attentionChangedP2();
    void signalQualityChangedP1();
    void signalQualityChangedP2();
public slots:
    void readyRead();
    void UDPStreamStarted();
    void UDPStreamStopped();
};
#endif // UDPHELPER_H
