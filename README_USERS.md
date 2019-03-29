# Users

## Overview
The Users Microservice consists of two containers:

* users-db
* users

The dedicated repository for this microservice can be found [here](https://github.com/microservices-cicd/users/).

### users-db
This is a MongoDB database. In our case this DB will deployed inside openshift - however it would be possible to use another DB which does not run on the platform itself, e.g. sources by your local ops team or - more likely - a cloud provider with a DBaaS offering.

### users
The service itself is written in Java and provides the shopping cart functionality.

## Deploying the microservice
To deploy the microservice, ensure you are logged in.
Deploy the DB first:
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

Afterwards the app itself:
```
oc new-app --name=user golang:1.7~https://github.com/microservices-cicd/user#master \
--strategy=docker \
-e MONGO_USER="user" \
-e MONGO_PASS="pass" \
-l stage=dev
```

Now, expose the user service:
```
oc expose dc/user --port=8080
```

In general, this behaviour is pretty similar to what we saw in the carts microservice. First a MongoDB is spawned, then the app itself. While we were using s2i in the carts example, again a s2i tool for Go is not used here, instead it's build from the Dockerfile which can be found in the root folder of the repository.
