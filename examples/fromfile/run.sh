#!/bin/bash -e

[[ $# -eq 0 ]] && echo "Usage: $0  <video.mp4>+" && exit 1

function GVV {
    git describe --abbrev --dirty --always --tags
}

function run {
    local FROMFILE="${FROMFILE:-./build/bin/fromfile}"
    local JSONS="${JSONS:-../testdata-univr.git/jsons}"

    local video="$1"
    local vid="$(basename "$video")"
    local gvv="$(GVV)"
    local gv="$(git rev-parse --short HEAD)"
    local gdate="$(git show --no-patch --format=%ci $gv)"
    local fqdn="$(hostname -f)"

    local path="$JSONS/$gv/$vid"
    local target="$path/$fqdn.json"
    [[ -f "$target" ]] && echo "Skipping $target..." && return
    mkdir -p "$path"

    make
    sleep 10
    $FROMFILE "$video" \
              "$vid" \
              "$gvv" \
              "$gv" \
              "$gdate" \
              "$fqdn" \
              2>"$target"
}


[[ "$(GVV)" == *-dirty ]] && echo Unstaged changes! && exit 2

# START_COMMIT=${START_COMMIT:-'testdata_fromfile_format_v2'}
# for sha in $(git rev-list $START_COMMIT~1...master); do
[[ -z "$SHA" ]] && echo '$SHA is unset' && exit 3
sha=$SHA
    echo "Processing $sha..."
    git checkout $sha
    for video in "$@"; do
        run "$video"
    done
    echo "Done with $sha"
    git checkout -
# done
