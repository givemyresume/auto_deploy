#!/bin/bash

cd /home/ubuntu/auto_deploy
docker-compose -p resumebuilder up | tee ./run.log