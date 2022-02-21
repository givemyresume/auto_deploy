#!/bin/bash

sudo docker-compose -f /home/ubuntu/auto_deploy/docker-compose.yml down
sudo docker-compose rm -f
sudo docker system prune -a
sudo docker-compose -f /home/ubuntu/auto_deploy/docker-compose.yml up --force-recreate --build -d