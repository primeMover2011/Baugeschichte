TARGET = tst_categoryloader

QT = core testlib positioning network
CONFIG += testcase c++11

INCLUDEPATH += ../../src

TESTDATA += category.json


HEADERS += ../../src/categoryloader.h \
    ../../src/housemarker.h
SOURCES += tst_categoryloader.cpp \
    ../../src/categoryloader.cpp \
    ../../src/housemarker.cpp

