#!/bin/bash

mkdir backup &> /dev/null
cp main.tf backup/main.tf
cp run_later.sh backup/run_later.sh 
cp server.conf backup/server.conf

if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found"
    echo "visit this url (https://learn.hashicorp.com/tutorials/terraform/install-cli) to install terraform-cli"
    echo "Run this script once terraform is installed"
    exit
fi

read -p "Do you have a terraform cloud remote backend? [y|N]: " hasTfCloud
echo
if [ "$hasTfCloud" == "y" ]; then
    echo "Make sure to set the following env variables on terraform cloud
        - AWS_ACCESS_KEY_ID
        - AWS_SECRET_ACCESS_KEY
        - TF_VAR_GITHUB_TOKEN
        - TF_VAR_FAUNA_DB_KEY
        - TF_VAR_SSH_PUB_KEY
        - TF_VAR_EMAIL_PASS
        - TF_VAR_API_URL"
else
    read -p "Do you want to run terraform locally? [y|N]: " runLocally
    echo
    if [ "$runLocally" == "y" ]; then
        sed -i '9,16d' main.tf

        if test -z "$AWS_ACCESS_KEY_ID"
        then
            read -p "AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
            echo
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
        else
            echo "AWS_ACCESS_KEY_ID is already set"
        fi

        if test -z "$AWS_SECRET_ACCESS_KEY"
        then
            read -s -p "AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
            echo
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
        else
            echo "AWS_SECRET_ACCESS_KEY is already set"
        fi

        if test -z "$GITHUB_TOKEN"
        then
            read -s -p "GITHUB_TOKEN: " GITHUB_TOKEN
            echo
            export GITHUB_TOKEN=$GITHUB_TOKEN
        else
            echo "GITHUB_TOKEN is already set"
        fi

        if test -z "$FAUNA_DB_KEY"
        then
            read -s -p "FAUNA_DB_KEY: " FAUNA_DB_KEY
            echo
            export FAUNA_DB_KEY=$FAUNA_DB_KEY
        else
            echo "FAUNA_DB_KEY is already set"
        fi

        if test -z "$EMAIL_PASS"
        then
            read -s -p "EMAIL_PASS: " EMAIL_PASS
            echo
            export EMAIL_PASS=$EMAIL_PASS
        else
            echo "EMAIL_PASS is already set"
        fi

        if test -z "$SSH_PUB_KEY"
        then
            read -p "SSH_PUB_KEY: " SSH_PUB_KEY
            echo
            export SSH_PUB_KEY=$SSH_PUB_KEY
        else
            echo "SSH_PUB_KEY is already set"
        fi

        if test -z "$API_URL"
        then
            read -p "API_URL: " API_URL
            echo
            export API_URL=$API_URL
        else
            echo "API_URL is already set"
        fi
    else
        mv backup/main.tf.bak main.tf
        mv backup/run_later.sh.bak run_later.sh
        mv backup/server.conf.bak server.conf
        rm -r backup
        echo "Exiting!!!"
        exit
    fi
fi

read -p "Do you have an Elastic IP? [y|N]: " hasEip
echo
if [ " $hasEip" == "y" ]; then
    read -p "Enter Elastic IP Allocation ID: " eipAllocId
    echo
    sed -i "s/\"eipalloc-085afc5d8993450ac\"/$eipAllocId/g" main.tf
else
    sed -i "s/\"eipalloc-085afc5d8993450ac\"/aws_eip.eip.allocation_id/g" main.tf
    echo "
resource \"aws_eip\" \"eip\" {
  vpc      = true
  instance = aws_instance.webserver.id
}

output \"eip_dns\" {
  value = aws_eip.eip.public_dns
}" >> main.tf
fi

echo "Enter your domain urls for ssl certificate generation"
read -p "API url: " apiUrl
echo
read -p "WEBSITE url: " appUrl
echo

sed -i "s/api.givemyresume.tech/$apiUrl/g" run_later.sh server.conf
sed -i "s/app.givemyresume.tech/$appUrl/g" run_later.sh server.conf

echo "Enter your email id for ssl certificate generation"
read -p "Email: " emailId
echo

sed -i "s/api.givemyresume.tech/$apiUrl/g" run_later.sh

terraform init

echo "All settings have been applied"
if [ "$hasTfCloud" == "y" ]; then
    echo "Run `terraform login` and then run `terraform apply`"
else
    echo "Run `terraform apply`"

echo "Once everything completes, visit $appUrl

Also, to revert to the default configuratons, run the below commands
mv backup/main.tf main.tf
mv backup/run_later.sh run_later.sh
mv backup/server.conf server.conf
rm -r backup
"
