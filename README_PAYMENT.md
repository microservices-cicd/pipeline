# Payment

## Overview
The Payment Microservice consists of only one container:

* payment

The dedicated repository for this microservice can be found [here](https://github.com/microservices-cicd/payment).

### payment
The microservice is written in Go. The sourcecode will be downloaded from Github. This repository also includes a Dockerfile, which will be used to build the image which can then be used to spawn the needed containers/pods.

## Deploying the microservice
To deploy the microservice, ensure you are logged in.
```
oc new-app --name=payment https://github.com/microservices-cicd/payment#master \
-l stage=dev
```

This time we do not even supply an image where this should build from. Instead, inside the repository a Dockerfile can be found. Openshift will use this Dockerfile to determine how to actually build the needed image and push it to the newly created ImageStream. The golang image in this case is pulled from DockerHub.

**Add information about updates when:**

* source changes
* refered image changes
