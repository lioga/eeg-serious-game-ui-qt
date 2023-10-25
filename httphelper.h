#ifndef HTTPHELPER_H
#define HTTPHELPER_H
#include "qnetworkaccessmanager.h"
#include "qnetworkrequest.h"
#include <QStandardItemModel>
#include <QUdpSocket>

class RequestManager;
class HTTPHelper : public QObject
{
    Q_OBJECT
public:

    explicit HTTPHelper(QObject *parent = nullptr);
    void GET(const QString url);
signals:
    void requestFinished(QString answer);
    void requestFailed(QString answer);
private:
    QNetworkAccessManager *manager;
    QNetworkRequest request;
    QUdpSocket *socket;
private slots:
    void managerFinished(QNetworkReply *reply);
};
#endif // HTTPHELPER_H
