# Orders

## Overview
The orders Microservice consists of two containers:

* orders-db
* orders

The dedicated repository for this microservice can be found [here](https://github.com/microservices-cicd/orders/).

### orders-db
This is a MongoDB. In our case this DB will deployed inside openshift - however it would be possible to use another DB which does not run on the platform itself, e.g. sources by your local ops team or - more likely - a cloud provider with a DBaaS offering.

### orders
The service itself is written in Java and allowes you to actually create orders.

## Deploying the microservice
To deploy the microservice, ensure you are logged in.
Deploy the DB first:
```
oc new-app --name=orders-db --template=mongodb-ephemeral \
--param=DATABASE_SERVICE_NAME=orders-db \
--param=MONGODB_USER=user \
--param=MONGODB_PASSWORD=pass \
--param=MONGODB_DATABASE=data \
--param=MONGODB_VERSION=3.2 \
-l stage=dev
```
As this works basically the same as in the carts, we will not dive much more into technical details.

Afterwards the app itself:
```
oc new-app --name=orders redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/orders#master \
-e PORT=8080 \
-e DB="user:pass@orders-db" \
-l stage=dev
```
As we can not find a Dockerfile in the root directory of the repository, it is safe to assume the S2I functionality will be used, especially since the prefix for the repository is the name of the image which will be used. We already saw this behaviour in the carts app.
