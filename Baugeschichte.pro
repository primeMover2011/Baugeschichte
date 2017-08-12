lessThan(QT_VERSION, "5.7.1") {
    warning("Qt 5.7.1 or above is required.")
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
