TEMPLATE = app

QT += qml quick positioning concurrent svg xml
android: QT += androidextras

SOURCES += main.cpp \
    dialog.cpp \
    housetrailimages.cpp \
    clusterproxy.cpp \
    Geohash.cpp


RESOURCES += qml.qrc
CONFIG += c++11

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

OPENCV3_PATH = D:\opencv3\android\OpenCV-3.0.0-android-sdk-1\OpenCV-android-sdk\sdk\native
OPENCV3_PATH_INCLUDE = $$OPENCV3_PATH + \jni\include
OPENCV3_PATH_LIBS =

# Default rules for deployment.


INCLUDE_PATH += OPENCV3_PATH_INCLUDE


include(deployment.pri)

HEADERS += \
    dialog.h \
    housetrailimages.h \
    clusterproxy.h \
    Geohash.hpp \
    Constants.hpp \
    Utility.hpp

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
