import QtQuick 2.3

Item {
    id: root
//custom check box
// public

    property bool   checked: false

    signal clicked(bool checked);   //onClicked:{root.checked = checked;  print('onClicked', checked)}

// private
    property real padding: 0.1    // around rectangle: percent of root.height
    property bool radio:   false  // false: check box, true: radio button

    width: 50;  height: 50                         // default size
    opacity: enabled  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state

    Rectangle { // check box (or circle for radio button)
        id: rectangle

        height: root.height * (1 - 2 * padding);  width: height // square
        x: padding * root.height
        anchors.verticalCenter: parent.verticalCenter
        border.width: 0.05 * root.height
        radius: (radio? 0.5: 0.2) * height



        Rectangle { // radio dot
            visible: checked  &&  radio
            color: 'black'
            width: 0.5 * parent.width;  height: width // square
            anchors.centerIn: parent
            radius: 0.5 * width // circle
        }
    }



    MouseArea {
        id: mouseArea

        enabled: !(radio  &&  checked) // selected RadioButton isn't selectable
        anchors.fill: parent

        onClicked: root.clicked(!checked) // emit
    }
}
