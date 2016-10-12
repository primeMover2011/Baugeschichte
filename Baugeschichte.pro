lessThan(QT_VERSION, "5.7.0") {
    error("Qt 5.7.0 or above is required.")
}

TEMPLATE = subdirs

SUBDIRS = src

android: {
} else {
ios: {
} else {
SUBDIRS += tests
}
}
