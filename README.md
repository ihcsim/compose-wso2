## compose-wso2

compose-wso2 sets up a collection of dockerized WSO2 components with a shared governance registry and SSO capability.

### Description

These are the components included:

1. API Manager
2. Data Service Server
3. Enterprise Service Bus
4. Governance Registry (back by MySQL)
5. Identity Server

### Before You Start

Before you get started with a `docker-compose up`, there are a few things you should know:

1. The WSO2 container images are quite large, ranging from 750MB to a whooping 1.0GB.
2. The first run of `docker-compose up` takes forever as the service images are pulled from my AWS S3 buckets, and the Governance Registry is started with the `-Dsetup` flag in order to initialize all the database tables. 
** Try run `docker-compose pull` prior to running `docker-compose up`.
3. Accessing the `/_system/governance/` mounted shared governance partition from the web console is also slow.
4. This project utilizes [Compose's networking feature](https://docs.docker.com/compose/networking/) to facilitate inter-containers networking communication.

### Usage

1. Set up default environmental variables: `source scripts/env.bash`
2. Pull services: `docker-compose pull <service>`
3. Run services: `docker-compose -p wso2 --x-networking up <service>`
4. Scale services: `docker-compose -p wso2 scale <service=counts>`
5. View logs: `docker-compose -p wso2 logs <service>`

### Web Admin Consoles

Components             | URL
---------------------- | -----------------------------
Identity Server        | https://$DOCKER_HOST:9443
API Manager            | https://$DOCKER_HOST:9444
Enterprise Service Bus | https://$DOCKER_HOST:9445
Data Service Server    | https://$DOCKER_HOST:9446
Governance Registry    | https://$DOCKER_HOST:9447

If you are using `docker-machine`, you can get the value of `$DOCKER_HOST` with `docker-machine ip <machine>`.

### Governance Registry Persistance

The [Governance Registry](http://wso2.com/products/governance-registry/) is used to provide a shared governance partition backed by a MySQL database, as documented [here](https://docs.wso2.com/display/ESB490/Governance+Partition+in+a+Remote+Registry). The database `registrydb` is created by the `scripts/mysql/init.sql` script on-start. 

To test the shared governance partition set-up, navigate to the `/_system/governance` registry from any of the web consoles. Add or modify some resources, and expect the changes to be seen in the web consoles of other components.

There are two others adjustments I had to make to get this to work:

1. Override the default MySQL `sql-mode` using the `conf/mysql/my.cnf` script to remove the [`NO_ZERO_IN_DATE`](http://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_zero_in_date) and [`NO_ZERO_DATE`](http://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_zero_date) restrictions. WSO2 uses `DEFAULT 0` in some of their timestamp queries.
2. Disable SSL by setting the `useSSL` parameter in the JDBC connection string as seen in the `conf/<component>/master-datasources.xml` script.

### Single Sign-On

Coming soon.

### Supported Environmental Variables

The default versions of the WSO2 components and MySQL credentials are found in the `scripts/env.bash` script.

Variables           | Description
------------------- | --------------------------------
APIM_VERSION        | Version of API Manager
DSS_VERSION         | Version of Data Service Server
ESB_VERSION         | Version of Enterprise Service Bus
GREG_VERSION        | Version of Governance Registry
MYSQL_VERSION       | Version of MySQL
MYSQL_ROOT_PASSWORD | MySQL root password

### Override MySQL Configurations

The default MySQL configurations can be overridden by adding custom configuration files, suffixed with the `.cnf` extension, to the `conf/mysql` folder. For more information, see the MySQL official repository on [dockerhub](https://hub.docker.com/_/mysql/).
