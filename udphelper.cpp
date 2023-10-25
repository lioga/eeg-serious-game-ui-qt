#include "udphelper.h"

//udp helper class for data stream

UDPHelper::UDPHelper(QObject *parent) :
    QObject(parent)
{
    socket = new QUdpSocket(this);
}


void UDPHelper::UDPStreamStarted(){
    connect(socket,SIGNAL(readyRead()),this,SLOT(readyRead()));
    socket->bind(QHostAddress("127.0.0.1"), 8082); //ip and port of udp host

    recievedBytes = new quint8[4]; //create a new quint8 and fill it with zeros
    for (int i = 0; i < 4; i++) {
        recievedBytes[i] = 0;
    }
}


void UDPHelper::readyRead() //when a readyread signal from the qudpsocket fires, code comes to this slot
{
    QByteArray Buffer;
    Buffer.resize(socket->pendingDatagramSize());

    QHostAddress sender;
    quint16 senderPort;
    socket->readDatagram(Buffer.data(),Buffer.size(),&sender,&senderPort);

    memcpy(recievedBytes, Buffer.data(), Buffer.size()); //copy the values of buffer into recivedBytes arr

    switch (recievedBytes[0]) { //decide player by looking at first bit
    case 1:
        emit attentionChangedP1();
        emit signalQualityChangedP1();
        qDebug() << "1. oyuncu";
        break;
    case 2:
        emit attentionChangedP2();
        emit signalQualityChangedP2();
        qDebug() << "2. oyuncu";
        break;
    default:
        qDebug() << "Unknown value: " << recievedBytes[0];
        break;
    }
}

int UDPHelper::readAttention() const {
    const int attention = recievedBytes[1];
    return attention;
}

int UDPHelper::readSignalQuality() const {
    const int signalQuality = recievedBytes[3];
    return signalQuality;
}

void UDPHelper::UDPStreamStopped(){
    //close socket, disconnect problem may arise because of this
    //we disconnect but we don't close the socket while doing it.

    disconnect(socket,SIGNAL(readyRead()),this,SLOT(readyRead()));
    socket->close();
}


