#!/bin/bash

# commands to run after everything is provisioned
# add ssl for all domains
sudo certbot --nginx -d app.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_app.log
sudo certbot --nginx -d api.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_api.log

# watch all the below repos for changes && pull
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/auto_deploy/api &
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/auto_deploy/website &
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/auto_deploy/api/givemyresume.github.io &