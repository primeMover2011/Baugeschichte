TEMPLATE = app

TARGET = Baugeschichte

QT += qml quick location positioning concurrent sensors svg xml sql
android {
    QT += androidextras
    contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
        # Qt does not deploy MapboxGL automaticly? :(
        ANDROID_EXTRA_LIBS += \
            /opt/Qt/5.9.1/android_armv7/plugins/geoservices/libplugins_geoservices_libqtgeoservices_mapboxgl.so
        ANDROID_EXTRA_LIBS += $$PWD/../../android-openssl-qt/prebuilt/armeabi-v7a/libcrypto.so
        ANDROID_EXTRA_LIBS += $$PWD/../../android-openssl-qt/prebuilt/armeabi-v7a/libssl.so
    }
    contains(ANDROID_TARGET_ARCH,x86) {
        # Qt does not deploy MapboxGL automaticly? :(
        ANDROID_EXTRA_LIBS = \
            /opt/Qt/5.9.1/android_x86/plugins/geoservices/libplugins_geoservices_libqtgeoservices_mapboxgl.so
        ANDROID_EXTRA_LIBS += $$PWD/../../android-openssl-qt/prebuilt/x86/libcrypto.so
        ANDROID_EXTRA_LIBS += $$PWD/../../android-openssl-qt/prebuilt/x86/libssl.so
    }
}
ios {
    QMAKE_INFO_PLIST = $$PWD/iOS/Info.plist
    BUNDLEID = at.bitschmiede.grazwiki
    QMAKE_ASSET_CATALOGS = $$PWD/ios/Images.xcassets
    QMAKE_ASSET_CATALOGS_APP_ICON = "AppIcon"
    #ios_icon.files = $$files($$PWD/iOS/AppIcons/*.png)
    #QMAKE_BUNDLE_DATA += ios_icon
    ios_artwork.files = $$files($$PWD/iOS/Screenshots/*.png)
    QMAKE_BUNDLE_DATA += ios_artwork
    app_launch_images.files = $$files($$PWD/iOS/splash*.png)
    QMAKE_BUNDLE_DATA += app_launch_images
    app_launch_screen.files = $$files($$PWD/iOS/LaunchScreen.xib)
    QMAKE_BUNDLE_DATA += app_launch_screen

    QMAKE_IOS_DEPLOYMENT_TARGET = 8.2
    # Note for devices: 1=iPhone, 2=iPad, 1,2=Universal.
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2
}


CONFIG += c++11

RESOURCES += qml.qrc \
    images.qrc \
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
    qml/qmldir \
    qml/ToolBar.qml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

include(deployment.pri)


# Supported languages
# qml sources
lupdate_only {
    SOURCES += qml/*.qml
}
LANGUAGES = de en
# used to create .ts files
 defineReplace(prependAll) {
     for(a,$$1):result += $$2$${a}$$3
     return($$result)
 }
# Available translations
TSNAME = Baugeschichte
tsroot = $$join(TSNAME,,,.ts)
tstarget = $$join(TSNAME,,,_)
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
