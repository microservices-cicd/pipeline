# Others

## Overview
This will deploy a bunch of services which are deployed with a single command. The tricks behind them were already explained in the previous steps. Services which will be deployed here are:

* payment - written in Go [Repository](https://github.com/microservices-cicd/payment/)
* rabbitmq - a Queue Manager used for messaging to e.g. store the orders
* queue-master - [Repository](https://github.com/microservices-cicd/queue-master/)
* shipping - [Repository](https://github.com/microservices-cicd/shipping/)

## Deploying the microservice

### payment
```
oc new-app --name=payment https://github.com/microservices-cicd/payment#master -l stage=dev
```

### rabbitmq
```
oc new-app --name=rabbitmq rabbitmq:3.6.8 -l stage=dev
```

### queue-master
```
oc new-app --name=queue-master redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/queue-master#master \
-e PORT=8080 \
-l stage=dev
```

### shipping
```
oc new-app --name=shipping redhat-openjdk18-openshift:1.2~https://github.com/microservices-cicd/shipping#master \
-e PORT=8080 \
-l stage=dev
