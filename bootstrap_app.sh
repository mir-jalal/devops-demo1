#!/usr/bin/env bash

echo "bootstrap_app Provisioning"

sudo apt-get update --fix-missing -y
sudo apt-get install openjdk-14-jdk -y
sudo apt-get install mysql-server -y

function pull_clone {
  Dir=$(basename "$1" .git)
  if [[ -d "$Dir" ]]; then
    cd $Dir
    git pull
  else
    git clone "$1" && cd $Dir
  fi
}

pull_clone https://gitlab.com/mir.jalal/demo1

chmod +x mvnw

./mvnw clean package
