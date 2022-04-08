#!/bin/bash

cd /home/ubuntu/auto_deploy 
sudo docker-compose down
sudo docker-compose up -d
cd -