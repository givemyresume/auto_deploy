#!/bin/bash

# commands to run after everything is provisioned
# add ssl for all domains
sudo certbot --nginx -d app.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_app.log
sudo certbot --nginx -d api.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_api.log
sudo certbot --nginx -d app1.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_app1.log
sudo certbot --nginx -d api1.givemyresume.tech -n -m balasubhayu99@gmail.com --eff-email --agree-tos | tee /home/ubuntu/logs/certbot_api1.log

# watch all the below repos for changes && pull
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/api >> /home/ubuntu/api.log &
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/website >> /home/ubuntu/website.log &
nohup /home/ubuntu/auto_deploy/git-repo-watcher -d /home/ubuntu/api/givemyresume.github.io >> /home/ubuntu/givemyresume.log &