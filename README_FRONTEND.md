# Frontend

## Overview
The frontend is the part which will be served to the user. It is made of only one container

* frontend

The dedicated repository for this microservice can be found [here](https://github.com/microservices-cicd/front-end/).

### frontend
The service itself is written in nodejs and provides the webinterface for the shop.

## Deploying the microservice
```
oc new-app --name=front-end nodejs:6~https://github.com/microservices-cicd/front-end#master \
-e PORT=8080 \
-l stage=dev
```

This will use the nodejs s2i image to build the image.

## Expose the service
We talked about services previously when accessing the database. Services are the way microservices *find* each other. Instead of configuring IP addresses of servers/containers, which may change a lot, we ususally just use service names. The service itself is usually implemented by HAProxy inside the platform, which will take care of routing and loadbalancing, in case something like this is used. This behaviour is refered as *Reverse Proxying*.

However, usually services are only interally reachable, from within one project. To access a service from another project or outside the platform, a [route](https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html) is needed.

### Creating the route
As Openshift generates a service for us (can be listed by using `oc get routes`), exposing it is as simple as it could be:
```
oc expose svc/front-end
```

Expose it, use the link you just created (issue `oc get routes` to see the routes) and open it in the browser. A socks shop should show up, however with a rather limited functionality. The reason behind this is easy: The services use Port 8080 for listening, while the microservice expects port 80 to be used. While it would be possible to change the service so they would listen on port 80, this would require major changes in the application. Instead of this, we can also simply change the service. Issue the following commands to change the ports for all services:
```
oc patch svc/user -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/shipping -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/queue-master -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/payment -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/orders -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/catalogue -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/carts -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
```
