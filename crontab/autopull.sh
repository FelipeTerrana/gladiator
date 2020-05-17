#!/bin/bash

eval $(ssh-agent -s)
ssh-add
git pull origin master
crontab crontab/crontabfile
cp docker/id_rsa /root/.ssh/
cp docker/id_rsa.pub /root/.ssh/
cp docker/known_hosts /root/.ssh/
