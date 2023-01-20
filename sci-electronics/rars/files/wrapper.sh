#!/usr/bin/env bash

# Wrap the jar file
DIR="%%INSTALLDIR%%"
JAR="%%JAR%%"
java -Dawt.useSystemAAFontSettings=on \
     -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
     -jar "${DIR}/${JAR}" "${@}"
