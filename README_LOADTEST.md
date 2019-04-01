# LoadTest

** CURRENTLY NOT WORKING **

## Overview
To ensure our application is actually working, let's do some requests. To see the increasing load, we have to create endpoints for prometheus to fetch, so the monitoring has some data we can later on display. We start exposing the needed URLs by adding the annotations.

### Prepare the loadtest, allow prometheus scraping
This will simply export all Deployment Controller, Services and Secrets, change the namespace, stage and version, and deploy it to the QA stage.

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

### Create the loadtest

This command will fetch the repository and build the image on the openshift node. When this is done, it get's pushed to an ImageStream.
```
oc new-build --name=load-test https://github.com/microservices-cicd/load-test#master \
-n m-cicd-dev
```

Now we can pull this image from the ImageStream and run in Openshift.
```
oc run -i -t load-test --image=172.30.253.62:5000/m-cicd-dev/load-test:latest \
--env="HOST=front-end-m-cicd-dev.app.azp18.appagile.de" \
--env="CLIENTS=5" \
--env="REQUESTS=10000" \
--restart=Never \
-n m-cicd-dev
```

Once we have generated enough load, simply delete the pod as this does not hold any kind of valuable information for us.
```
oc delete po load-test -n m-cicd-dev
```
