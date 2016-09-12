TEMPLATE = app

TARGET = Baugeschichte

QT += qml quick location positioning concurrent svg xml
android: QT += androidextras
ios {
#  LIBS += -L$$[QT_INSTALL_PLUGINS]/geoservices
#  QTPLUGIN += qtgeoservices_mapbox
}

CONFIG += c++11

RESOURCES += qml.qrc

SOURCES += main.cpp \
    houselocationfilter.cpp \
    applicationcore.cpp \
    markerloader.cpp \
    housemarker.cpp \
    housemarkermodel.cpp \
    categoryloader.cpp

HEADERS += \
    houselocationfilter.h \
    applicationcore.h \
    markerloader.h \
    housemarker.h \
    housemarkermodel.h \
    categoryloader.h

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

include(deployment.pri)

