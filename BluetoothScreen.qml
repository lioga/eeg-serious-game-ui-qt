import QtQuick 2.3
import QtQuick.Controls 2.0
import ListViewModel 1.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
ApplicationWindow {
    id: bluetoothroot
    width: 800; height: 480
    Rectangle {
        id:parentItem
        anchors.fill: parent
        clip: true
        color: "#1f1f1f"

        Component.onCompleted : { //by removing all items, force users to rescan
            bluetoothList.removeAllItems();
        }

        ////// for controlling button enable orders
        property bool isBluetoothOnClicked : false
        property bool isScanClicked : false
        property bool isConnectClicked : false

        ColumnLayout{
            anchors.topMargin: 10
            anchors.fill: parent;
            id: columnlay
            spacing: 20
            RowLayout{ //first row: buttons and scan popup

                Button{
                    id: bluetoothOnButton
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 70
                    Layout.leftMargin: 10
                    text: "Bluetooth Aç"
                    onClicked: {
                        bluetoothList.turnONBluetooth();
                        parentItem.isBluetoothOnClicked = true
                    }
                }
                Button{
                    id: bluetoothOffButton
                    Layout.alignment: Qt.AlignHCenter

                    Layout.preferredHeight: 70
                    text: "Bluetooth Kapat"
                    enabled: parentItem.isBluetoothOnClicked
                    onClicked: {
                        bluetoothList.turnOFFBluetooth();
                        parentItem.isBluetoothOnClicked = false
                        parentItem.isScanClicked = false
                    }
                }
                Button{
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 70
                    text: "Cihaz Tara"
                    enabled: parentItem.isBluetoothOnClicked
                    onClicked: {
                        scanPopup.open();
                        bluetoothList.scanBluetoothDevices();
                        parentItem.isScanClicked = true
                    }
                }
                Popup{ //during the scan process this popup appears and waits for the
                        //isScanFinished variable in C++ to be true, look at connections below
                    id: scanPopup
                    width: 250
                    height: 150
                    x:275
                    y:165
                    background: Rectangle{
                        radius: 40
                    }
                    ColumnLayout{
                        anchors.centerIn: parent
                        Text {
                            text: "Taranıyor..."
                            font.bold: false
                            font.italic: true
                            font.pixelSize: 24
                            color: "#353637"
                            Layout.alignment: Qt.AlignHCenter
                            anchors.topMargin: 40
                        }
                        BusyIndicator{
                            id:scanPopupBusyIndicator
                            Layout.alignment: Qt.AlignHCenter
                            running: true
                        }

                    }
                    closePolicy: Popup.CloseOnEscape //popup closes on escape,
                    //for only code based method wanted, change it to => Popup.NoAutoClose


                }
                Button{
                    id: connectButton
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 70
                    text: "Bağlan"
                    enabled: parentItem.isScanClicked
                    onClicked: {
                        bluetoothList.connectBluetooth();
                        parentItem.isConnectClicked = true
                    }
            }
                Button{
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 70
                    enabled: parentItem.isConnectClicked
                    text: "Bağlantıyı Kes"
                    onClicked: {
                        bluetoothList.disconnectBluetooth();
                    }
            }
                TextField { //shows system messages, throws typeerror occasionally, doesnt broke app
                    id:serverTextField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: parent
                    Layout.rightMargin: 10
                    Layout.preferredHeight: 70
                    readOnly: true
                    placeholderText: "Sistem Mesajları"
                    text: bluetoothList.serverMessage
                }
            }
            RowLayout{ //mac addresses and names text
                spacing: -630
                Text {
                    id: bluetoothMacAddresses
                    Layout.leftMargin: 55
                    text: "MAC Adresleri"
                    Layout.fillWidth: true
                    color: "#fbfbfb"
                    font.pointSize: 16
                    font.bold: true
                    visible: false
                }
                Text {
                    id: bluetoothNames
                    text: "İsimler"
                    Layout.fillWidth: true
                    color: "#fbfbfb"
                    font.pointSize: 16
                    font.bold: true
                    visible: false
                }
            }
            ListView { //listview
                id: column
                Layout.alignment: Qt.AlignBottom
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true

                model: ListViewModel {
                    id: listModel
                    list: bluetoothList
                }

                delegate:
                    RowLayout {
                    Layout.fillWidth: true
                    CustomCheckBox{ //custom radiobox, only one checkable, when checked updates C++ side
                        radio:true
                        checked:  model.done = column.currentIndex == index
                        onClicked: {
                            model.done = checked
                            column.currentIndex  = index
                        }
                    }
                    Text { //gets texts from the handleScan method in C++
                        text: model.description
                        Layout.fillWidth: true
                        color: "#fbfbfb"
                        font.pointSize: 18
                    }
                }
            }
            Button{
                Layout.preferredHeight: 70
                text: "Tamamlandı"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
                onClicked: {

                    bluetoothroot.close()
                }
            }
        }

    }
    Connections {
        target: bluetoothList
        onIsScanFinishedChanged: {
            var isScanFinished = bluetoothList.getIsScanFinished();
            if (isScanFinished){
                scanPopup.close()
                bluetoothMacAddresses.visible = true
                bluetoothNames.visible = true
                scanPopupBusyIndicator.running = isScanFinished

                connectButton.enabled = true
                bluetoothOnButton.enabled = true
                bluetoothOffButton.enabled = true

            } else{
                bluetoothOnButton.enabled = false
                bluetoothOffButton.enabled = false
                connectButton.enabled = false

            }
        }
    }

}
