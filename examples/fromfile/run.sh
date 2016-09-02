#!/bin/bash

# Usage: $0  <video.mp4>

FROMFILE="${FROMFILE:-./build/bin/fromfile}"

$FROMFILE \
    "$(git describe --abbrev --dirty --always --tags)" \
    "$(hostname -f)" \
    "$1"
