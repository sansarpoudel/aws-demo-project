#!/bin/bash
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker run -i -t -d -p80:80 --name demo-nginx nginx
