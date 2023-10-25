#include "httphelper.h"
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>

//http helper class for handling async communication

HTTPHelper::HTTPHelper(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    connect(manager, &QNetworkAccessManager::finished, this, &HTTPHelper::managerFinished);
}

void HTTPHelper::GET(QString url)
{
    manager->get(QNetworkRequest(QUrl(url)));
}

void HTTPHelper::managerFinished(QNetworkReply *reply)
{

    if (reply->error()) {
        qDebug() << reply->errorString();
        emit requestFinished("ERROR");
        qDebug() << "manager sends error";
        return;
    }
    QString answer = reply->readAll();
    emit requestFinished(answer);
}
