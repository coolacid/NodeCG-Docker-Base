#!/bin/bash

for DIR in $(ls)
do
    echo Getting deps for $DIR
    cd $DIR
    npm install && bower install
    cd /home/node/nodecg/bundles
done
