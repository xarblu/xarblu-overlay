#!/usr/bin/env bash

# Wrap the jar file
DIR="%%INSTALLDIR%%"
JAR="%%JAR%%"
java -jar "${DIR}/${JAR}" "${@}"
