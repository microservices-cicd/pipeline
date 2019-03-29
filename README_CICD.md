# CI/CD with Jenkins

## Overview
CI/CD is a pattern which allowes the dev team to deploy fast, often and in a safe manner. It also ensures that in case a version has still bugs, a rollback can easily be performed. Openshift heavily supports such pattern.

The Idea behind CI/CD is to deploy rather often and small to keep possible deployment errors contained and reduce the complexity. By automating the deployment, your artifacts can be transfered from one stage to the next, without actually rebuilding the software - simly by moving the image and modifying the run parameter of the image. In the end, this means you can run the same image in dev, int and prod.

### Creating the projects

We need two more projects. One will hold the Jenkins we use for CI/CD, the other one is the project where our *stage* (called qa) will be implemented.

```
oc new-project m-cicd-qa
oc new-project m-cicd-jenkins
```

### Allowing access to other projects

To make this possible, Jenkins needs the ability to manage our environments. We can easily use a service account for that, so it can't be used to access the platform from outside.
```
oc policy add-role-to-user edit system:serviceaccount:m-cicd-jenkins:jenkins -n m-cicd-dev
oc policy add-role-to-user edit system:serviceaccount:m-cicd-jenkins:jenkins -n m-cicd-qa
```

### Mirroring DEV to QA
This will simply export all Deployment Controller, Services and Secrets, change the namespace, stage and version, and deploy it to the QA stage.

```
oc new-app -f https://raw.githubusercontent.com/microservices-cicd/pipeline/master/stage-pipeline.yaml \
-p CURRENT_NAMESPACE=m-cicd-dev \
-p NAMESPACE=m-cicd-qa \
-p VERSION=v1.2 \
-p CURRENT_STAGE=dev \
-p NEXT_STAGE=qa \
-n m-cicd-jenkins
```

### Moving single services through stages
This pipeline however works much more granular. It allows you to to redeploy each service with a certain tag to the next stage.

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

## Blue/Green with Jenkins

### Overview
Blue Green Deployments allow you to rapidly test changes between two versions. For this, both versions are deployed and you create two routes. However, the same backend services are still used, which make changes and their results much easier to track.

### Deploying the Blue/Green Pipeline
```
oc new-app --name=front-end-blue nodejs:6~https://github.com/microservices-cicd/front-end#blue \
-e PORT=8080 \
-l stage=dev \
-n m-cicd-dev

oc expose service/front-end-blue -n m-cicd-dev
```

## A/B Test with Jenkins

### Overview
A/B tests take the Blue/Green approach one step further. Instead of creating two routes, we create only one and balance the traffic accoring to a defined distribution key.

### Create the Front-End for A/B testing
```
oc expose svc/front-end --name front-end-ab

oc edit route route/front-end-ab
```

Build the specs parts along this:
```
  alternateBackends:
  - kind: Service
    name: front-end-blue
    weight: 50
  host: front-end-ab-mro-socksshop.aotp012.mcs-paas.io
  port:
    targetPort: 8080-tcp
  to:
    kind: Service
    name: front-end
    weight: 50
  wildcardPolicy: None
```

Use `oc get routes` to get the correct link and test the routing. Please use different browsers to check or delete cookies, so it won't create sticky sessions and glue us to one service.1
