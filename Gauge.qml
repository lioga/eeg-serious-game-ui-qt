import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Extras.Private 1.0
import QtGraphicalEffects 1.0

CircularGauge {
    id: gauge

    property color strokeColor
    property color backgroundColor
    property color backgroundStrokeColor
    property color gaugeColor
    Component.onCompleted: forceActiveFocus()

    Behavior on value { NumberAnimation { duration: 100 }} // duration can be updated for changing animation speed on gauge

    style: CircularGaugeStyle {

        labelStepSize: 10
        labelInset: outerRadius / 2.2
        tickmarkInset: outerRadius / 4.2
        minorTickmarkInset: outerRadius / 4.2
        minimumValueAngle: -100
        maximumValueAngle: 100

        background: Rectangle {
            implicitHeight: gauge.height
            implicitWidth: 10
            color: backgroundColor
            anchors.centerIn: parent
            radius: 360
            Rectangle{
                implicitHeight: parent.height * 0.7
                implicitWidth: parent.width * 0.7
                color: gaugeColor
                anchors.centerIn: parent
                radius: 360

            }
            Canvas { //part that updates on value changed
                property int value: gauge.value
                anchors.fill: parent
                onValueChanged: requestPaint()

                function degreesToRadians(degrees) {
                  return degrees * (Math.PI / 180);
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.beginPath();
                    ctx.strokeStyle = strokeColor;
                    ctx.lineWidth = outerRadius * 0.3
                    ctx.arc(outerRadius,
                          outerRadius,
                          outerRadius - ctx.lineWidth / 2,
                          degreesToRadians(valueToAngle(gauge.minimumValue - 1 ) - 90),
                          degreesToRadians(valueToAngle(gauge.value) - 90));

                    ctx.stroke();
                }
            }
            Canvas { //canvas for covering the bottom half side of the gauge
                property int value: gauge.value
                anchors.fill: parent

                function degreesToRadians(degrees) {
                  return degrees * (Math.PI / 180);
                }

                onPaint: {
                    var context = getContext("2d");
                    context.lineWidth = outerRadius * 0.3 + 10
                    context.arc(outerRadius,outerRadius,(outerRadius - context.lineWidth / 2) + 5,
                                degreesToRadians(10),degreesToRadians(168));
                    context.strokeStyle = backgroundStrokeColor;
                    context.stroke();
                }
            }

        }

        foreground: Item { //numbers located at the middle of the gauge
            Text {
                id: speedLabel
                anchors.centerIn: parent
                text: gauge.value.toFixed(0)
                font.pixelSize: outerRadius * 0.3
                color: "white"
                antialiasing: true
            }
        }
        needle: Rectangle { //not used, needle
            y: outerRadius * 0.15
            implicitWidth: outerRadius * 0.03
            implicitHeight: outerRadius * 0.9
            antialiasing: true
            color: "transparent"
        }
        tickmarkLabel:  Text { //not used, label
            font.pixelSize: Math.max(6, outerRadius * 0.05)
            text: styleData.value
            color: styleData.value <= gauge.value ? "transparent" : "transparent"
            antialiasing: true
            visible: false
        }

        tickmark: Rectangle{ //not used, tickmark
            visible : false
        }

        minorTickmark: Rectangle { //not used, minortickmark
            implicitWidth: outerRadius * 0.01
            implicitHeight: outerRadius * 0.03
            visible: false
            antialiasing: true
            smooth: true
            color: styleData.value <= gauge.value ? "transparent" : "transparent"
        }

    }
}
