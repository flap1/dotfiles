#!/bin/bash

# Update packages
sudo apt update

# Install Python and pip
sudo apt install -y python3 python3-pip

# Upgrade pip
pip3 install --upgrade pip

# Install Ansible
pip3 install ansible
