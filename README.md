# Microservices CICD

## create project 
```
oc new-project m-cicd-dev
```

## carts-db
- type: mongodb

### crate app
```
oc new-app --name=carts-db --template=mongodb-ephemeral \
--param=DATABASE_SERVICE_NAME=carts-db \
--param=MONGODB_USER=user \
--param=MONGODB_PASSWORD=pass \
--param=MONGODB_DATABASE=data \
--param=MONGODB_VERSION=3.2 \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=carts-db
```


## carts (https://github.com/microservices-cicd/carts)
- type: java

### create app
```
oc new-app --name=carts redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/carts#master \
-e PORT=8080 \
-e DB="user:pass@carts-db" \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=carts
```


## catalogue-db (https://github.com/microservices-cicd/catalogue)
- type: mysql

### modifications
- docker/catalogue-db/data/mysql-init/90-init-db.sh
```
init_arbitrary_database() {
  local thisdir
  local init_data_file
  thisdir=$(dirname ${BASH_SOURCE[0]})
  init_data_file=$(readlink -f ${thisdir}/../dump.sql)
  log_info "Initializing the arbitrary database from file ${init_data_file}..."
  mysql $mysql_flags ${MYSQL_DATABASE} < ${init_data_file}
}

if ! [ -v MYSQL_RUNNING_AS_SLAVE ] && $MYSQL_DATADIR_FIRST_INIT ; then
  init_arbitrary_database
fi
```

### create app
```
oc new-app --name=catalogue-db mysql:5.7~https://github.com/microservices-cicd/catalogue#master \
--context-dir=docker/catalogue-db/data \
-e MYSQL_DATABASE=socksdb \
-e MYSQL_USER=user \
-e MYSQL_PASSWORD=pass \
-e MYSQL_ROOT_PASSWORD=fake_password \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=catalogue-db
```


## catalogue (https://github.com/microservices-cicd/catalogue)
- type: go

### modifications
- /Dockerfile
```
FROM golang:1.7

COPY . /go/src/github.com/microservices-demo/catalogue
WORKDIR /go/src/github.com/microservices-demo/catalogue

RUN go get -u github.com/FiloSottile/gvt
RUN gvt restore && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app github.com/microservices-demo/catalogue/cmd/cataloguesvc

WORKDIR /
COPY images/ /images/

RUN	chmod +x /app

ARG BUILD_DATE
ARG BUILD_VERSION
ARG COMMIT

LABEL org.label-schema.vendor="Weaveworks" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.version="${BUILD_VERSION}" \
  org.label-schema.name="Socks Shop: Catalogue" \
  org.label-schema.description="REST API for Catalogue service" \
  org.label-schema.url="https://github.com/microservices-demo/catalogue" \
  org.label-schema.vcs-url="github.com:microservices-demo/catalogue.git" \
  org.label-schema.vcs-ref="${COMMIT}" \
  org.label-schema.schema-version="1.0"

CMD ["/app", "-port=8080"]
EXPOSE 8080
```

### create app
```
oc new-app --name=catalogue https://github.com/microservices-cicd/catalogue#master -l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=catalogue
```


## front-end (https://github.com/microservices-cicd/front-end)
- type:nodejs

### create app
```
oc new-app --name=front-end nodejs:6~https://github.com/microservices-cicd/front-end#master \
-e PORT=8080 \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=front-end
```


## orders-db
- type: mongodb

### crate app
```
oc new-app --name=orders-db --template=mongodb-ephemeral \
--param=DATABASE_SERVICE_NAME=orders-db \
--param=MONGODB_USER=user \
--param=MONGODB_PASSWORD=pass \
--param=MONGODB_DATABASE=data \
--param=MONGODB_VERSION=3.2 \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=orders-db
```


## orders (https://github.com/microservices-cicd/orders)
- type: java

### create app
```
oc new-app --name=orders redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/orders#master \
-e PORT=8080 \
-e DB="user:pass@orders-db" \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=orders
```


## payment (https://github.com/microservices-cicd/payment)
- type:go

### modifications
- /Dockerfile
```
FROM golang:1.7

RUN mkdir /app
COPY . /go/src/github.com/microservices-demo/payment/

RUN go get -u github.com/FiloSottile/gvt
RUN cd /go/src/github.com/microservices-demo/payment/ && gvt restore

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/main github.com/microservices-demo/payment/cmd/paymentsvc

CMD ["/app/main", "-port=8080"]
EXPOSE 8080
```

### create app
```
oc new-app --name=payment https://github.com/microservices-cicd/payment#master -l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=payment
```

## rabbitmq
- type:rabbitmq

### create app
```
oc new-app --name=rabbitmq rabbitmq:3.6.8 -l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=rabbitmq
```

## queue-master (https://github.com/microservices-cicd/queue-master)
- type:java

### create app
```
oc new-app --name=queue-master redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/queue-master#master \
-e PORT=8080 \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=queue-master
```

## shipping (https://github.com/microservices-cicd/shipping)
- type:java

### create app
```
oc new-app --name=shipping redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/shipping#master \
-e PORT=8080 \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=shipping
```

## user-db (https://github.com/microservices-cicd/user/tree/master/docker/user-db)
- type:mongodb

### modifications
- /docker/user-db/mongodb-init/90-create-insert.sh
```
FILES=$APP_DATA/scripts/*-create.js
for f in $FILES; do mongo -u $MONGODB_USER -p $MONGODB_PASSWORD localhost:27017/users $f; done

FILES=$APP_DATA/scripts/*-insert.js
for f in $FILES; do mongo -u $MONGODB_USER -p $MONGODB_PASSWORD localhost:27017/users $f; done
```

### create app
```
oc new-app --name=user-db mongodb:3.2~https://github.com/microservices-cicd/user#master \
--context-dir=docker/user-db \
-e DATABASE_SERVICE_NAME=user-db \
-e MONGODB_USER=user \
-e MONGODB_PASSWORD=pass \
-e MONGODB_DATABASE=users \
-e MONGODB_ADMIN_PASSWORD=admin \
-l stage=dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=user-db
```

## user (https://github.com/microservices-cicd/user)
- type:go

### modifications
- /Dockerfile
```
FROM golang:1.7-alpine

COPY . /go/src/github.com/microservices-demo/user/
WORKDIR /go/src/github.com/microservices-demo/user/

RUN go get -v github.com/Masterminds/glide
RUN glide install && CGO_ENABLED=0 go build -a -installsuffix cgo -o /user main.go

ENV HATEAOS user
ENV USER_DATABASE mongodb
ENV MONGO_HOST user-db

WORKDIR /
EXPOSE 8080

RUN	chmod +x /user

CMD ["/user", "-port=8080"]
```

### create app
```
oc new-app --name=user golang:1.7~https://github.com/microservices-cicd/user#master \
--strategy=docker \
-e MONGO_USER="user" \
-e MONGO_PASS="pass" \
-l stage=dev

oc expose dc/user --port=8080
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=user
```

## change ports
```
oc patch svc/user -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/shipping -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/queue-master -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/payment -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/orders -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/catalogue -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/carts -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
```

## create route for the frontend
```
oc expose service/front-end
```

## jenkins

## create a new m-cicd-qa project
```
oc new-project m-cicd-qa
```

### create jenkins project
```
oc new-project m-cicd-jenkins
```

### allow jenkins to access m-cicd-dev and m-cicd-qa projects
```
oc policy add-role-to-user edit system:serviceaccount:m-cicd-jenkins:jenkins -n m-cicd-dev
oc policy add-role-to-user edit system:serviceaccount:m-cicd-jenkins:jenkins -n m-cicd-qa
```

### pipeline stage from dev to qa
```
oc new-app -f https://raw.githubusercontent.com/microservices-cicd/pipeline/master/stage-pipeline.yaml \
-p CURRENT_NAMESPACE=m-cicd-dev \
-p NAMESPACE=m-cicd-qa \
-p VERSION=v1.2 \
-p CURRENT_STAGE=dev \
-p NEXT_STAGE=qa \
-n m-cicd-jenkins
```

### pipeline for single microservice
```
oc new-app -f https://raw.githubusercontent.com/microservices-cicd/pipeline/master/app-pipeline.yaml \
-p CURRENT_NAMESPACE=m-cicd-dev \
-p NAMESPACE=m-cicd-qa \
-p VERSION=v1.3 \
-p CURRENT_STAGE=dev \
-p NEXT_STAGE=qa \
-p APP=front-end \
-n m-cicd-jenkins
```

## Blue/Green
### create app
```
oc new-app --name=front-end-blue nodejs:6~https://github.com/microservices-cicd/front-end#blue \
-e PORT=8080 \
-l stage=dev \
-n m-cicd-dev

oc expose service/front-end-blue -n m-cicd-dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l app=front-end-blue -n m-cicd-dev
```

## Azure Service
### RedisCache
```
oc set env --from=configmap/redis-cache dc/front-end -n m-cicd-dev
```

### MongoDB
```
oc set env --from=configmap/azure-mongo dc/orders -n m-cicd-dev
```

## AutoScale
### Resource Limits: front-end
- CPU Request: 50 millicores
- CPU Limit: 150 millicores

### Autoscale Deployment Config
- Min Pods: 1
- Max Pods: 3
- CPU Request Target: 80%

### cleanup
```
oc delete hpa/front-end -n m-cicd-dev
```

## LoadTest
### enable prometheus metrics
```
oc patch dc/catalogue \
-p '[{"op": "replace", "path": "/spec/template/metadata/annotations", "value":{"prometheus.io/scrape":"true", "prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}]' \
--type=json \
-n m-cicd-dev

oc patch dc/carts \
-p '[{"op": "replace", "path": "/spec/template/metadata/annotations", "value":{"prometheus.io/scrape":"true", "prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}]' \
--type=json \
-n m-cicd-dev

oc patch dc/orders \
-p '[{"op": "replace", "path": "/spec/template/metadata/annotations", "value":{"prometheus.io/scrape":"true", "prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}]' \
--type=json \
-n m-cicd-dev

oc patch dc/payment \
-p '[{"op": "replace", "path": "/spec/template/metadata/annotations", "value":{"prometheus.io/scrape":"true", "prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}]' \
--type=json \
-n m-cicd-dev

oc patch dc/shipping \
-p '[{"op": "replace", "path": "/spec/template/metadata/annotations", "value":{"prometheus.io/scrape":"true", "prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}]' \
--type=json \
-n m-cicd-dev

oc patch dc/user \
-p '[{"op": "replace", "path": "/spec/template/metadata/annotations", "value":{"prometheus.io/scrape":"true", "prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}]' \
--type=json \
-n m-cicd-dev

oc patch dc/user \
-p '[{"op": "add", "path": "/spec/template/spec/containers/0/ports", "value":{"ports":[{"containerPort":"8080", "protocol":"TCP"}]}}]' \
--type=json \
-n m-cicd-dev

oc patch dc/front-end \
-p '[{"op": "replace", "path": "/spec/template/metadata/annotations", "value":{"prometheus.io/scrape":"true", "prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}]' \
--type=json \
-n m-cicd-dev
```

### create app
```
oc new-build --name=load-test https://github.com/microservices-cicd/load-test#master \
-n m-cicd-dev

oc run -i -t load-test --image=172.30.253.62:5000/m-cicd-dev/load-test:latest \
--env="HOST=front-end-m-cicd-dev.app.azp18.appagile.de" \
--env="CLIENTS=5" \
--env="REQUESTS=10000" \
--restart=Never \
-n m-cicd-dev

oc delete po load-test -n m-cicd-dev
```

### cleanup
```
oc delete dc,bc,builds,sa,svc,po,is,secret -l build=load-test -n m-cicd-dev
oc delete po load-test -n m-cicd-dev
```


