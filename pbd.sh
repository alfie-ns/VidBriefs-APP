#!/bin/bash

# Push-Backout-Delete

./push.sh #push to repo
sleep 5 #5sec sleep
cd .. # go backwards
rm -rf Vidbriefs-APP # delete repo

