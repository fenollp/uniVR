#!/bin/bash -e

[[ $# -ne 1 ]] && echo "Usage: $0  <video.mp4>" && exit 1

function run {
    local FROMFILE="${FROMFILE:-./build/bin/fromfile}"
    local JSONS="${JSONS:-../testdata-univr.git/jsons}"

    local video="$1"
    local vid="$(basename "$video")"
    local gv="$(git describe --abbrev --dirty --always --tags)"
    local gdate="$(git show -s --format=%ci ${gv%%-*})"
    local fqdn="$(hostname -f)"

    local path="$JSONS/$gv/$vid"
    mkdir -p "$path"

    $FROMFILE "$video" \
              "$vid" \
              "$gv" \
              "$gdate" \
              "$fqdn" \
              2> "$path/$fqdn.json"
}

run "$@"
