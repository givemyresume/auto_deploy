#!/bin/sh
sudo apt update
sudo apt install nginx python3-pip -y
sudo systemctl enable nginx
sudo systemctl start nginx
git clone https://github.com/givemyresume/website.git
git clone https://github.com/givemyresume/api.git
cd api
git clone https://github.com/givemyresume/givemyresume.github.io.git
cd ..
adduser -u 5678 --disabled-password --gecos "" appuser && chown -R /api /website
sudo cp {website/website,api/api}.conf /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/{website,api}.conf /etc/nginx/sites-enabled/
sudo systemctl reload nginx