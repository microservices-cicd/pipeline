# Catalogue

## Overview
The Catalogue Microservice consists of two containers:

* catalogue-db
* catalogue

The dedicated repository for this microservice can be found [here](https://github.com/microservices-cicd/catalogue/).

### catalogue-db
This is a MySQL database. In our case this DB will deployed inside openshift - however it would be possible to use another DB which does not run on the platform itself, e.g. sources by your local ops team or - more likely - a cloud provider with a DBaaS offering.

### catalogue
The service itself is written in Go and provides the shopping cart functionality.

## Deploying the microservice
To deploy the microservice, ensure you are logged in.
Deploy the DB first:
```
oc new-app --name=catalogue-db mysql:5.7~https://github.com/microservices-cicd/catalogue#master \
--context-dir=docker/catalogue-db/data \
-e MYSQL_DATABASE=socksdb \
-e MYSQL_USER=user \
-e MYSQL_PASSWORD=pass \
-e MYSQL_ROOT_PASSWORD=fake_password \
-l stage=dev
```
Please mind the `--context-dir` statement here. Often you will find scripts for populating a database with values within the repository that holds the code - as in this case. Using the context-dir allows you to specify a folder which is used for the source2image build process. In this case, this is used for extending the mysql-image (which would just create an empty mysql db). Further documentation on this can be found in the [README for the s2i image using MySQL/MariaDB](https://github.com/sclorg/mysql-container/tree/master/5.7#extending-image).

Afterwards the app itself:
```
oc new-app --name=catalogue https://github.com/microservices-cicd/catalogue#master -l stage=dev
```

Again this will build from a Dockerfile found in the root of the repository. In case you want to use an external database, please mind that the connection string is (currently hardcoded)[https://github.com/microservices-demo/catalogue/blob/master/cmd/cataloguesvc/main.go#L48].
