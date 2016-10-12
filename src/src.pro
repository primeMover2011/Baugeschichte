TEMPLATE = app

TARGET = Baugeschichte

QT += qml quick location positioning concurrent svg xml
android {
    QT += androidextras
}
ios {
#  LIBS += -L$$[QT_INSTALL_PLUGINS]/geoservices
#  QTPLUGIN += qtgeoservices_mapbox
}

CONFIG += c++11

RESOURCES += qml.qrc \
    ../translations/translations.qrc

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
    android/gradlew.bat \

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

include(deployment.pri)


# Supported languages
# qml sources
lupdate_only {
    SOURCES += *.qml
}
LANGUAGES = de en
# used to create .ts files
 defineReplace(prependAll) {
     for(a,$$1):result += $$2$${a}$$3
     return($$result)
 }
# Available translations
tsroot = $$join(TARGET,,,.ts)
tstarget = $$join(TARGET,,,_)
TRANSLATIONS = $$PWD/../translations/$$tsroot
TRANSLATIONS += $$prependAll(LANGUAGES, $$PWD/../translations/$$tstarget, .ts)

# run LRELEASE to generate the qm files
qtPrepareTool(LRELEASE, lrelease)
message($$TRANSLATIONS)
 for(tsfile, TRANSLATIONS) {
     message($$tsfile)
     command = $$LRELEASE $$tsfile
     system($$command)|error("Failed to run: $$command")
 }
