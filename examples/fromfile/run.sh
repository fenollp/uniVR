#!/bin/bash -e

[[ $# -ne 1 ]] && echo "Usage: $0  <video.mp4>" && exit 1

function run {
    local FROMFILE="${FROMFILE:-./build/bin/fromfile}"
    local JSONS="${JSONS:-../testdata-univr.git/jsons}"

    local gv="$(git describe --abbrev --dirty --always --tags)"
    local vid="$1"
    local fqdn="$(hostname -f)"

    local tmp=$RANDOM.json

    $FROMFILE "$vid" \
              "$gv" \
              "$fqdn" \
              "$(basename "$vid")" \
              2> $tmp

    local path="$JSONS/$gv/$(basename "$vid")"
    mkdir -p "$path"
    mv $tmp "$path/$fqdn.json"
}

run "$@"
