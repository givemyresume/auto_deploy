#!/bin/bash

sudo docker-compose -f /home/ubuntu/auto_deploy/docker-compose.yml down
sudo docker-compose -f /home/ubuntu/auto_deploy/docker-compose.yml up -d