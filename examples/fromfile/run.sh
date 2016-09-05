#!/bin/bash -e

[[ $# -ne 1 ]] && echo "Usage: $0  <video.mp4>" && exit 1

function run {
    local FROMFILE="${FROMFILE:-./build/bin/fromfile}"
    local JSONS="${JSONS:-../testdata-univr.git/jsons}"

    local video="$1"
    local vid="$(basename "$video")"
    local gvv="$(git describe --abbrev --dirty --always --tags)"
    local gv="$(git rev-parse --short HEAD)"
    local gdate="$(git show --no-patch --format=%ci $gv)"
    local fqdn="$(hostname -f)"

    [[ "$gvv" == *-dirty ]] && echo Unstaged changes! && exit 2

    local path="$JSONS/$gv/$vid"
    local target="$path/$fqdn.json"
    [[ -f "$target" ]] && return
    mkdir -p "$path"

    $FROMFILE "$video" \
              "$vid" \
              "$gvv" \
              "$gv" \
              "$gdate" \
              "$fqdn" \
              2>"$target"
}


START_COMMIT=${START_COMMIT:-'testdata_fromfile_format_v0'}
for sha in $(git rev-list $START_COMMIT~1...); do
    echo "Processing $sha..."
    git checkout $sha
    make
    sleep 10
    run "$@"
    echo "Done with $sha"
    git checkout -
done
