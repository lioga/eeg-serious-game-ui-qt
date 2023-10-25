#ifndef BLUETOOTHMODEL_H
#define BLUETOOTHMODEL_H

#include <QAbstractListModel>

#include "bluetoothlist.h"
Q_DECLARE_METATYPE(QModelIndex)
class BluetoothList;

class ListViewModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(BluetoothList *list READ list WRITE setList)

public:
    explicit ListViewModel(QObject *parent = nullptr);

    enum {
        DoneRole = Qt::UserRole + 1,
        DescriptionRole

    };

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;
    virtual QHash<int, QByteArray> roleNames() const override;
    BluetoothList *list() const;
    void setList(BluetoothList *list);




private:
    BluetoothList *mList;


};

#endif // BLUETOOTHMODEL_H
