#!/bin/bash

# commands to run after everything is provisioned
sudo certbot --nginx -d app.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_app.log
sudo certbot --nginx -d api.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_api.log
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/api >> /home/ubuntu/api.log &
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/website >> /home/ubuntu/website.log &
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/api/givemyresume.github.io >> /home/ubuntu/givemyresume.log &