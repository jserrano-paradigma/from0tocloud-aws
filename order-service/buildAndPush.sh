#!/bin/bash

echo "Getting AWS ECR Credentials"
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 129822709161.dkr.ecr.eu-west-1.amazonaws.com

echo "Building, tagging and pushing new image"
docker build -t order-service .
docker tag order-service:latest 129822709161.dkr.ecr.eu-west-1.amazonaws.com/order-service:latest
docker push 129822709161.dkr.ecr.eu-west-1.amazonaws.com/order-service:latest

echo "Done ;-)"

