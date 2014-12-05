#!/bin/bash

# Generate CSV files from videos
#   (./fromfile needs to be accessible thusly)

r=$HOME/wefwefwef/nvr

exe=${exe:-fromfile}
landmarks=$r/shape_predictor_68_face_landmarks.dat

for vid_dir in $r/videos2; do # for each dir
    for v in $vid_dir/*; do # for each video
        echo "$v"
        mkdir -p test/csv_${exe}
        csv=test/csv_${exe}/$(basename "$v" '.mp4').csv
        for i in `seq 1 3`; do # a few times
            echo Pass $i
            ./$exe $landmarks "$v" > "$csv"
        done
        sleep 5
    done
done
