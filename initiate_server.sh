#!/bin/sh
sudo apt update
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
cd /var/www/html
sudo git clone https://github.com/subhayu99/subhayu99.github.io
sudo mv subhayu99.github.io/* .
sudo rm -rf subhayu99.github.io/