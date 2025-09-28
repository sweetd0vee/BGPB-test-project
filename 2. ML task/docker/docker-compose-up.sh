#!/bin/bash


export COMPOSE_PROJECT_NAME=bgps

docker-compose -f docker-compose.yml up -d
