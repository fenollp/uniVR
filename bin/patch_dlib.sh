#!/bin/bash

# 


for cmk in $(git grep -EnI -i -l include_directories -- dlib-*); do
    echo $cmk
    sed -i 's/include_directories(\([^S]\)/include_directories(SYSTEM \1/gI' $cmk
done
