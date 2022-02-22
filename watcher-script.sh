#!/bin/bash

cd /home/ubuntu/auto_deploy 
sudo docker-compose build --no-cache
sudo docker-compose up -d
cd -