# Carts

## Overview
The Carts Microservice consists of two containers:

* carts-db
* carts

The dedicated repository for this microservice can be found [here](https://github.com/microservices-cicd/carts/).

### carts-db
This is a MongoDB database. In our case this DB will deployed inside openshift - however it would be possible to use another DB which does not run on the platform itself, e.g. sources by your local ops team or - more likely - a cloud provider with a DBaaS offering.

### carts
The service itself is written in Java and provides the shopping cart functionality.

## Deploying the microservice
To deploy the microservice, ensure you are logged in.
Deploy the DB first:
```
oc new-app --name=carts-db --template=mongodb-ephemeral \
--param DATABASE_SERVICE_NAME=carts-db \
--param MONGODB_USER=user \
--param MONGODB_PASSWORD=pass \
--param MONGODB_DATABASE=data \
--param MONGODB_VERSION=3.2 \
-l stage=dev
```
The param-variable is used for further execution of the template called mongodb-ephermal. By default openshift would at first look in your own project for such a template, and if it can't be found there, look at the project called `openshift`. To take a look at the template, execute `oc describe template/mongodb-ephemeral -n openshift`. For the actual template definition, `oc get template/mongodb-ephermal -n openshift -o yaml` can be used for printing the file in yaml. Another available format would be `json`.

Afterwards the app itself:
```
oc new-app --name=carts redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/carts#master \
-e PORT=8080 \
-e DB="user:pass@carts-db" \
-l stage=dev
```
In this case, we supplied an ImageStream with a certain version and a Docker Repository. By this we will use a mechanism called [Source2Image](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/builds_and_image_streams.html#source-build). Openshift will

* Clone the Docker Repository
* Create an ImageStream, a BuildConfig and a DeploymentConfig
* Build the Image via BuildConfig and
* Push the Image to the ImageStream
* This will trigger the DeploymentConfig to deploy containers from this ImageStream

The ImageStream for the openjdk is supplied by the Openshift platform. Unless an according ImageStream is found in your own project, Openshift will look up imagestreams in the `openshift` project. To get all public available ImageStreams, you can issue `oc get is -n openshift`. Further exploration of this image can be done by issuing `oc get is/redhat-openjdk18-openshift -n openshift -oyaml`.

In case you want to use an external database, only deploy the app and modify the environment variable supplied as DB. In our case the internal name resolution  via [services](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/pods_and_services.html) is used to find the container avaiable as `carts-db` (see the service name above), for an external DB this would probably be something along `DB="user:pass@cartsdb.example.com"`.
