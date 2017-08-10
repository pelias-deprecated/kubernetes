#!/bin/bash -ex

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get upgrade -y

echo "elasticsearch soft nofile 128000\n
elasticsearch hard nofile 128000\n
root soft nofile 128000\n
root hard nofile 128000" | sudo tee --append /etc/security/limits.conf

echo "fs.file-max = 500000" | sudo tee --append /etc/sysctl.conf
