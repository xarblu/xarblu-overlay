#!/usr/bin/env bash

# Wrap the jar file
DIR="%%INSTALLDIR%%"
JAR="%%JAR%%"
java -Dawt.useSystemAAFontSettings=on \
     -jar "${DIR}/${JAR}" "${@}"
