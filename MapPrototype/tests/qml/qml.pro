TEMPLATE = app

TARGET = qmlTests

CONFIG += warn_on qmltestcase

SOURCES += tst_qmltests.cpp

TESTDATA += \
    $$PWD/tst_RouteLine.qml

OTHER_FILES += \
    $$PWD/data/*
