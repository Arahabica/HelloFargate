#!/bin/bash

# This is memo.

######
# 作成系

## Dockerfile => Docker Image
docker build -t test-express .

## Docker Image => Docker Container
# 3000 => Docker Container内で定義しているポート
# 3005 => 外部からアクセスするポート
# my-app-342 => 愛称
# test-express:1.0 => Docker Image
docker run -it --rm -p 3005:3000 --name my-app-342 test-express:latest

# デーモンモード
docker run -it --rm -d -p 3005:3000 --name my-app-342 test-express:latest

######
# 参照系

## list Docker image list
docker image list
# REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
# test-express            1.0                 0362f3b42af2        14 minutes ago      71.1MB
# XXXX                    X.X                 406f227b21f5        9 months ago        68.1MB


## list Docker image list
docker image list
# REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
# test-express            1.0                 0362f3b42af2        14 minutes ago      71.1MB
# XXXX                    X.X                 406f227b21f5        9 months ago        68.1MB

## list Docker Container list
#  docker container list と同じ
docker ps
# CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                    NAMES
# 34c616109f79        test-express:1.0        "npm start"              2 minutes ago       Up 2 minutes        0.0.0.0:3005->3000/tcp   my-app-342
# 1f655e11922c        hogehoge                "java -jar DynamoDBL…"   4 hours ago         Up 3 hours          0.0.0.0:8000->8000/tcp   inspiring_kare

######
# 削除系

## delete Docker Image
docker rmi ${IMAGE_ID}

## delete Docker Container
docker rm -f ${CONTAINER_ID}

## delete all Docker Container
docker rm -f $(docker ps -aq)


######
# 接続系

## コンテナ内に入る
docker exec -it ${CONTAINER_ID} /bin/sh

# コンテナにつけた名前を利用して、コンテナ内に入る
# ex) $CONTAINER_NAME=my-app-342
docker exec -it $(docker ps -f "Name=${CONTAINER_NAME}" -aq) /bin/sh


######
# AWS系

# ECSのリポジトリを作成
# AWS => ECS => Repository => Create Repository

# ECSのリポジトリにイメージをプッシュする
# `aws ecr get-login --no-include-email --profile your-alias`
`aws ecr get-login --no-include-email`
docker build -t test-express .
docker tag test-express:latest 636061485504.dkr.ecr.ap-northeast-1.amazonaws.com/test-express-repo:latest
docker push 636061485504.dkr.ecr.ap-northeast-1.amazonaws.com/test-express-repo:latest
