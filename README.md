
## 作成系

### Dockerfile => Docker Image
```
docker build -t test-express .
```

### Docker Image => Docker Container

```
docker run -it --rm -p 3005:80 --name my-app-342 test-express:latest
```

* 80 => Docker Container内で定義しているポート
* 3005 => 外部からアクセスするポート
* my-app-342 => 愛称
* test-express:1.0 => Docker Image

```
docker run -it --rm -d -p 3005:80 --name my-app-342 test-express:latest
```

* デーモンモード

## 参照系

### list Docker images

```
docker image list
```

```
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
test-express            1.0                 0362f3b42af2        14 minutes ago      71.1MB
XXXX                    X.X                 406f227b21f5        9 months ago        68.1MB
```


### list Docker Containers

`docker container list` も同じ

```
docker ps
```

```
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                    NAMES
34c616109f79        test-express:1.0        "npm start"              2 minutes ago       Up 2 minutes        0.0.0.0:3005->3000/tcp   my-app-342
1f655e11922c        hogehoge                "java -jar DynamoDBL…"   4 hours ago         Up 3 hours          0.0.0.0:8000->8000/tcp   inspiring_kare
```

## 削除系

### delete Docker Image
```
docker rmi ${IMAGE_ID}
```
### delete Docker Container
```
docker rm -f ${CONTAINER_ID}
```
### delete all Docker Container
```
docker rm -f $(docker ps -aq)
```

## 接続系

### コンテナ内に入る
```
docker exec -it ${CONTAINER_ID} /bin/sh
```

## コンテナにつけた名前を利用して、コンテナ内に入る
ex) `$CONTAINER_NAME=my-app-342`

```
docker exec -it $(docker ps -f "Name=${CONTAINER_NAME}" -aq) /bin/sh
```

## AWS系

### ECSのリポジトリ(ECR)を作成

AWS => ECS => Repository => Create Repository

```
REPOSITORY=test-express

`aws ecr get-login --no-include-email`
aws ecr create-repository --repository-name ${REPOSITORY}
```

### ECSのリポジトリ(ECR)を作成してイメージをプッシュする

```
REPOSITORY=test-express
AWS_ACCOUNT_ID=436999999999
AWS_REGION=ap-northeast-1

`aws ecr get-login --no-include-email`
aws ecr create-repository --repository-name ${REPOSITORY}
docker build -t ${REPOSITORY} .
docker tag test-express:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:latest
echo  ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:latest
```
### Fargate上で動くWebサービスにALB経由でアクセス

#### 1. ALB設置

##### 1.1 Target Group作成

`EC2` => `Target Groups` => `Create target group` => `Target type` を `IP` にする！

##### 1.2 ALB作成

`EC2` => `Load Balancers` => `Create Load Balancer` => `ALB`
=> (中略) => `Configure Routing` => `Target Group`
=> 1.1で作ったTarget Group を指定


#### 2 Task Definition作成

`ECS` => `Task Definitions` => `Create new Task Definition`
=> `Fargate` => `Container Definitions` => `Add container`
=> `Image`に`ECR`に登録されているURLを記入する。末尾に`:latest`をつける。
=> `Port mappings`にContainerが露出しているポートを設定する

#### 3. ECS Cluster 設置

`ECS` => `Clusters` => `Create Cluster` => `Networking only`


#### 3. ECS Cluster Service 登録

`ECS` => `Clusters` => 作成したCluster
=> `Services` => `Create`
=> LaunchType: `Fargate` => Task Definitionに作成したTask Definitionを設定
=> Load balancer type: `Application Load Balancer`
=> Load balancer name: 作ったALB => `Container to load balance`
=> `Add to load balancer` => Target group name: 作ったTarget group


### ECS Clusterのコンテナ内のログ出力

ClusterにServiceを立てると勝手にCloudFlontにコンテナ内のログが出力されるようになる。

### ECS Cluster Serviceのログ出力

```
aws ecs --region ap-northeast-1 describe-services --cluster test-express-cluster --services test-express-s-2 | jq '.services[].events[].message'
```