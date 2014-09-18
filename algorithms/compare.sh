#!/bin/bash

# Compares 5 algorithms & 3 cascades.

videod=$HOME/wefwefwef/nvr/videos
outd=$HOME/wefwefwef/nvr/outs

xmls=('haarcascade_eye.xml' 'haarcascade_frontalface_alt.xml' 'lbpcascade_frontalface.xml')
names=('eye' 'face' 'lbpface')
scales=(1.1 1.3)

for vid in $videod/*; do
    [[ ! -f $vid ]] && continue
    video=$(basename $vid)
    i=0
    for xml in "${xmls[@]}"; do
        for scale in "${scales[@]}"; do
            name=${names[$i]}_${scale}_${video}
            echo $outd/$name
            ./_/build/_ xml/$xml $scale $videod/$video $outd/$name.tsv
        done
        ((i++))
    done
done
