#!/bin/bash

VERSION="v7.2.0"
sudo curl -L -o /usr/local/bin/aws-vault "https://github.com/99designs/aws-vault/releases/download/$VERSION/aws-vault-linux-amd64"
sudo chmod 755 /usr/local/bin/aws-vault

