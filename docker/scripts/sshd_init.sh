#!/bin/bash

mkdir ~/.ssh
mkdir -p /var/run/sshd
chmod 600 ~/.ssh
chmod 600 /etc/ssh/*
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo $PUBLIC_KEY >>~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
