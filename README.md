# Microservices CICD

## carts-db
- type: mongo db

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
- type: mysql db

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
- type:node js

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
- type: mongo db

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
- type:mongo db

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
