TEMPLATE = app

TARGET = qmlTests

CONFIG += warn_on qmltestcase

SOURCES += tst_qmltests.cpp

TESTDATA += \
    $$PWD/tst_DetailsModel.qml \
    $$PWD/tst_RouteLine.qml \
    $$PWD/tst_SearchModel.qml

OTHER_FILES += \
    $$PWD/data/*

DISTFILES += \
    tst_SearchModel.qml
