QT += qml quick

QT += network
QT += widgets
CONFIG += c++11

SOURCES += main.cpp \
    bluetoothlist.cpp \
    httphelper.cpp \
    listviewmodel.cpp \
    udphelper.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    main.qml \
    Gauge.qml \
    BluetoothScreen.qml \
    CustomCheckBox.qml

HEADERS += \
    bluetoothlist.h \
    httphelper.h \
    listviewmodel.h \
    udphelper.h
