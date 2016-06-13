lessThan(QT_VERSION, "5.6.0") {
    error("Qt 5.6.0 or above is required.")
}

TEMPLATE = subdirs

SUBDIRS += \
    src \
    tests
