#include "listviewmodel.h"
#include <QDebug>
#include "bluetoothlist.h"

//required for listview functionality in qml, most of them inherited virtual functions required to be implemented.
//just for the custom list functionality in qml

ListViewModel::ListViewModel(QObject *parent)
    : QAbstractListModel(parent)
    , mList(nullptr)
{
}

int ListViewModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid() || !mList)
        return 0;

    return mList->items().size();
}


QVariant ListViewModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mList)
        return QVariant();

    const BluetoothItem item = mList->items().at(index.row());
    switch (role) {
    case DoneRole:
        return QVariant(item.done);
    case DescriptionRole:
        return QVariant(item.description);
    }

    return QVariant();
}

bool ListViewModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!mList)
        return false;

    BluetoothItem item = mList->items().at(index.row());

    switch (role) {
    case DoneRole:
        item.done = value.toBool();
        break;

    case DescriptionRole:
        item.description = value.toString();
        break;
    }

    if (mList->setItemAt(index.row(), item)) {
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

Qt::ItemFlags ListViewModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable | Qt::ItemIsSelectable;;
}

QHash<int, QByteArray> ListViewModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[DoneRole] = "done";
    names[DescriptionRole] = "description";
    return names;
}

BluetoothList *ListViewModel::list() const
{
    return mList;
}

void ListViewModel::setList(BluetoothList *list)
{
    beginResetModel();

    if (mList)
        mList->disconnect(this);

    mList = list;

    if (mList) {
        connect(mList, &BluetoothList::preItemAppended, this, [=]() {
            const int index = mList->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });
        connect(mList, &BluetoothList::postItemAppended, this, [=]() {
            endInsertRows();
        });

        connect(mList, &BluetoothList::preItemRemoved, this, [=](int index) {
            beginRemoveRows(QModelIndex(), index, index);
        });
        connect(mList, &BluetoothList::postItemRemoved, this, [=]() {
            endRemoveRows();
        });
    }

    endResetModel();
}





