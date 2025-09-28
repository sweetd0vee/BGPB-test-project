#!/usr/bin/env bash

IMAGE=arina/bgps
TAG=master

cd ..

docker build -t $IMAGE:$TAG .

