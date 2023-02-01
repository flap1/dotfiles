#!/bin/bash

# jenv
git clone https://github.com/jenv/jenv.git ~/.jenv
sudo apt install openjdk-19-jdk openjdk-11-jdk
jenv add /usr/lib/jvm/java-19-openjdk-amd64
jenv add /usr/lib/jvm/java-11-openjdk-amd64
source ~/.config/zsh/sh/post_load.zsh

# gradle
VERSION=7.5.1
wget https://services.gradle.org/distributions/gradle-${VERSION}-bin.zip -P /tmp
sudo unzip -d /opt/gradle /tmp/gradle-${VERSION}-bin.zip
sudo ln -s /opt/gradle/gradle-${VERSION} /opt/gradle/latest

