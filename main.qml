import QtQuick 2.7
import QtQuick.Controls 2.0
import QtCharts 2.15
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: root
    width: 800
    height: 480
    visible: true
    //visibility: "FullScreen"

    property int serverTryCount: 0

    //for closing bluetoothscreen when server fails
    property var bluetoothScreenObject: ApplicationWindow

    //for updating x axis of charts
    property int chartp1x: 0
    property int  chartp2x : 0

    Component.onCompleted : { //check server when started, if you don't want to check comment the lines below
        waitServerAwakePopup.open();
        waitServerAwakePopup.amIOpen = true;
        bluetoothList.isServerAwake();
    }

    Popup{ //check server popup, disables everything if this popup is on the screen
           //look connections below for implementation
        property bool amIOpen: false
        id: waitServerAwakePopup
        width: 650
        height: 250
        anchors.centerIn: parent
        background: Rectangle{
            radius: 40
        }
        ColumnLayout{
            anchors.centerIn: parent
            Text {
                id: serverPopupText
                text: "Server Bekleniyor..."
                font.bold: false
                font.italic: true
                font.pixelSize: 26
                color: "#353637"
                Layout.alignment: Qt.AlignHCenter
                anchors.topMargin: 40
            }
        }
        closePolicy: Popup.NoAutoClose
    }
    Rectangle {
        id:rootRectangle
        anchors.fill: parent
        color: "#1f1f1f"
        Layout.topMargin: 10
        Drawer {  //side menu, stores buttons
            id: drawer
            enabled: true
            width: 0.33 * root.width
            height: root.height
            background: Rectangle{color:"#f9f9f9"}

            ColumnLayout{
                anchors.fill: parent;
                Button{
                    id: startStreamButton
                    enabled: true
                    Layout.topMargin: 10
                    text: "Başla!"
                    font.pointSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredHeight: 100
                    onClicked: {
                        bluetoothList.startUDPStream();
                        drawer.close()
                        startStreamButton.enabled = false //disables start enables stop button
                        stopStreamButton.enabled = true
                    }
                }
                Button{
                    text: "Bluetooth Ayarları"
                    Layout.fillWidth: true
                    font.pointSize: 14
                    font.bold: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredHeight: 100

                    onClicked: {
                        var component = Qt.createComponent("BluetoothScreen.qml")
                        var window    = component.createObject(root)
                        bluetoothScreenObject = window
                        window.show() //window.showFullScreen()
                        drawer.close()
                    }

                }
                Button{
                    id: stopStreamButton
                    enabled: false
                    text: "Bitir"
                    font.pointSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredHeight: 100
                    onClicked: {
                        bluetoothList.stopUDPStream();
                        //when stop clicked zeros everything
                        player1.value = 0
                        player2.value = 0
                        player1SignalQualityText.text = "0"
                        player2SignalQualityText.text = "0"
                        player1SignalQualityOuterRectangle.color = "red"
                        player2SignalQualityOuterRectangle.color = "red"

                        drawer.close()
                        startStreamButton.enabled = true //disables stop enables start button
                        stopStreamButton.enabled = false
                    }

                }
                Button{
                    text: "Çıkış"
                    font.pointSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredHeight: 100
                    onClicked: {
                        Qt.quit()
                    }

                }

                Rectangle{ //hacky fix for the height problem
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color:"#f9f9f9"
                }

            }
        }
        Button{ //opens the side menu
            id: sideMenuButton
            x:10
            y:10
            implicitWidth : 55
            implicitHeight: 55
            enabled: false
            background: Rectangle {
                color: "#fbfbfb"
                radius: 100
            }
            onClicked: {
                drawer.open()
            }
            text: "|||"

        }
        //UI for signal quality, their colors and values are depend on Connections section below
        Rectangle{
            id:player1SignalQualityOuterRectangle
            x: 335
            y: 60
            width: 40
            height: 40
            color: player1.backgroundColor
            radius: 100
            Rectangle{
                anchors.centerIn: parent
                color: rootRectangle.color
                width: parent.width * 0.7
                height: parent.height * 0.7
                radius: 100
            }
            Text {
                id: player1SignalQualityText
                text: " "
                color: "white"
                anchors.centerIn: parent
            }
        }
        Rectangle{
            id:player2SignalQualityOuterRectangle
            x: 435
            y: 60
            width: 40
            height: 40
            color: player2.backgroundColor
            radius: 100
            Rectangle{
                anchors.centerIn: parent
                color: rootRectangle.color
                width: parent.width * 0.7
                height: parent.height * 0.7
                radius: 100
            }
            Text {
                id: player2SignalQualityText
                text: " "
                color: "white"
                anchors.centerIn: parent
            }
        }
        ColumnLayout{ //gauges and charts
            anchors.fill: parent;
            id: mcolumnlay
            spacing: -50

            RowLayout{
                Item {
                    Layout.topMargin: 20
                    Layout.preferredWidth : 400
                    Layout.preferredHeight: 240
                    Layout.alignment: Qt.AlignLeft
                    Gauge{
                        id: player1
                        anchors.fill: parent
                        strokeColor: "chartreuse"
                        backgroundColor: "green"
                        gaugeColor: rootRectangle.color
                        backgroundStrokeColor: rootRectangle.color

                    }
                }
                Item {
                    Layout.topMargin: 20
                    Layout.preferredWidth : 400
                    Layout.preferredHeight: 240
                    Layout.alignment: Qt.AlignRight
                    Gauge{
                        id: player2
                        anchors.fill: parent
                        strokeColor: "cyan"
                        backgroundColor:"darkblue"
                        gaugeColor: rootRectangle.color
                        backgroundStrokeColor: rootRectangle.color
                    }
                }
            }
            RowLayout{//hacky fix for height problem
                Rectangle{

                    width: 150
                    height: 50
                    color: rootRectangle.color
                }
            }
            RowLayout{//charts
                Item {
                    width: 350
                    height: 200
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    ChartView {
                        id: chartViewP1
                        width: parent.width
                        height: parent.height
                        anchors.fill: parent
                        animationOptions: ChartView.NoAnimation
                        antialiasing: true
                        backgroundColor: rootRectangle.color
                        legend.visible: false
                        ValueAxis {
                            id: axisYP1
                            min: 0
                            max: 100
                            gridVisible: false
                            color: "#fcfcfc"
                            labelsColor: "#fcfcfc"
                            labelFormat: "%.0f"

                        }
                        ValueAxis {
                            id: axisXP1
                            min: 0
                            max: 50
                            gridVisible: false
                            color: "#fcfcfc"
                            labelsColor: "#fcfcfc"
                            labelFormat: "%.0f"
                            tickCount: 5
                        }
                        //if spline wanted, just change LineSeries to SplineSeries
                        LineSeries {
                            id: lineSeriesP1
                            name: "signal 1"
                            color: "#7fff00"
                            axisX: axisXP1
                            axisY: axisYP1
                        }
                    }
                }
                Rectangle{
                    width: 50
                    height: 50
                    color: rootRectangle.color
                }
                Item {
                    width: 350
                    height: 200
                    Layout.alignment: Qt.AlignRight

                    Layout.fillHeight: true
                    ChartView {
                        id: chartViewP2
                        width: parent.width
                        height: parent.height
                        anchors.fill: parent
                        animationOptions: ChartView.NoAnimation
                        antialiasing: true
                        backgroundColor: rootRectangle.color
                        legend.visible: false
                        ValueAxis {
                            id: axisYP2
                            min: 0
                            max: 100
                            gridVisible: false
                            color: "#ffffff"
                            labelsColor: "#ffffff"
                            labelFormat: "%.0f"
                        }
                        ValueAxis {
                            id: axisXP2
                            min: 0
                            max: 50
                            gridVisible: false
                            color: "#ffffff"
                            labelsColor: "#ffffff"
                            labelFormat: "%.0f"
                            tickCount: 5
                        }
                        //if spline wanted, just change LineSeries to SplineSeries
                        LineSeries {
                            id: lineSeriesP2
                            name: "signal 1"
                            color: "#00ffff"
                            axisX: axisXP2
                            axisY: axisYP2
                        }
                    }
                }

            }
        }
    }
    Connections {
        target: mindwaveData
        onAttentionChangedP1: { //when attention changed emitted in udphelper, update line series
                                //if data is more than 10, delete first item, determines how many points present on the chart
            if(lineSeriesP1.count > 10)
                lineSeriesP1.remove(0);
            lineSeriesP1.append(chartp1x, mindwaveData.readAttention)
            chartp1x += 1
            axisXP1.min = lineSeriesP1.at(0).x
            axisXP1.max = lineSeriesP1.at(lineSeriesP1.count-1).x
        }
    }
    Connections {
        target: mindwaveData
        onAttentionChangedP2: {
            if(lineSeriesP2.count > 10)
                lineSeriesP2.remove(0);
            lineSeriesP2.append(chartp2x, mindwaveData.readAttention)
            chartp2x += 1
            axisXP2.min = lineSeriesP2.at(0).x
            axisXP2.max = lineSeriesP2.at(lineSeriesP2.count-1).x

        }
    }
    Connections {
        target: mindwaveData
        onAttentionChangedP1: {
            player1.value = mindwaveData.readAttention
        }
    }
    Connections { //update gauge values when attention changed emitted from udphelper
        target: mindwaveData
        onAttentionChangedP2: {
            player2.value = mindwaveData.readAttention
        }
    }
    Connections {//update signal values when signal quality changed emitted from udphelper
                 //if signal quality is lower than 200, signalquality circle is red
        target: mindwaveData
        onSignalQualityChangedP1: {
            player1SignalQualityText.text= mindwaveData.readSignalQuality.toString()
            player1SignalQualityOuterRectangle.color =  mindwaveData.readSignalQuality == 200 ?  "green" :  "red"
        }
    }
    Connections {
        target: mindwaveData
        onSignalQualityChangedP2: {
            player2SignalQualityText.text= mindwaveData.readSignalQuality.toString()
            player2SignalQualityOuterRectangle.color =  mindwaveData.readSignalQuality == 200 ? "darkblue" : "red"
        }
    }

    Connections { //check if server is awake
        target: bluetoothList
        onIsServerAwakeChanged: {
            var isServerAwake = bluetoothList.getServerStatus; //get server status

            if (isServerAwake){
                serverPopupText.color = "#353637"
                serverPopupText.text = "Sistem Hazır"
                timerServerSuccess.start() // server is ready, show success message in this timer
            }else{
                //server is not awake, open popup if it is not open
                if(!waitServerAwakePopup.amIOpen){
                    waitServerAwakePopup.open()
                    if (bluetoothScreenObject)  //close the bluetooth screen if it's open
                        bluetoothScreenObject.close()
                    waitServerAwakePopup.amIOpen = true
                    drawer.enabled = false
                    sideMenuButton.enabled = false
                    serverTryCount = 0
                }
                serverPopupText.color = "red"
                serverPopupText.text = "Server Bağlantı Hatası! Tekrar Deneniyor... (" + serverTryCount.toString() + ")"
                serverTryCount = serverTryCount + 1
                timerServerFailed.start() //check server condition in an interval
            }
        }
    }
    Timer{
        id:timerServerSuccess //server is awake, notify the user by showing success message
                              //in the period of timerRepeatServerSuccess, then start the timerRepeatServerSuccess
                              // for checking server condition consistanly
        repeat: false
        onTriggered: {
            waitServerAwakePopup.close()
            sideMenuButton.enabled = true
            drawer.enabled = true
            waitServerAwakePopup.amIOpen = false
            timerServerSuccess.stop()

            timerRepeatServerSuccess.repeat = true
            timerRepeatServerSuccess.interval = 10000 //determine the interval for cheking the server
            timerRepeatServerSuccess.start()          //in the case of success
        }
    }
    Timer{
        id:timerServerFailed //server connection failed, try again
        interval: 3000
        repeat: false
        onTriggered: {
            bluetoothList.isServerAwake();
            timerServerFailed.stop()
        }
    }
    Timer{
        id:timerRepeatServerSuccess //timer that controls if the server is up consistantly after success
        repeat: false //default values, new values written in the timerServerSuccess
        onTriggered: {
            var isScanFinished = bluetoothList.getIsScanFinished();
            var isConnectFinished = bluetoothList.getIsConnectFinished();
            console.log(isScanFinished && isConnectFinished)
            if (isScanFinished && isConnectFinished){
                bluetoothList.isServerAwake();
            }
        }
    }
}
