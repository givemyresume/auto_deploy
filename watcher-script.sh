#!/bin/bash

cd /home/ubuntu/auto_deploy 
sudo docker-compose down
sudo docker-compose rm -f
sudo docker-compose up --force-recreate --build -d
cd -