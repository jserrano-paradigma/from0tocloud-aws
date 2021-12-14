#!/bin/bash

echo "Building and pushing all images..."

echo "Building API Gateway"
cd api-gateway/; ./buildAndPush.sh; cd -
echo "Building Eureka Server"
cd eureka-server/; ./buildAndPush.sh; cd -
echo "Building User Service"
cd user-service/; ./buildAndPush.sh; cd -
echo "Building Category Service"
cd category-service/; ./buildAndPush.sh; cd -
echo "Building Item service"
cd item-service/; ./buildAndPush.sh; cd -
echo "Building Order Service"
cd order-service/; ./buildAndPush.sh; cd -

echo "Done! ;-)"










