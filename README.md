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
** To reduce the annoyance, run `docker-compose pull` prior to running `docker-compose up`.
3. Accessing the `/_system/governance/` mounted shared governance partition from the web console is also slow.

### Usage

* Set up default environmental variables: `source scripts/env.bash`
* Pull services: `docker-compose pull <service>`
* Run services: `docker-compose up <service>`
* Scale services: `docker-compose scale <service=counts>`

### Web Admin Consoles

Components             | URL
---------------------- | ----------------------
API Manager            | https://localhost:9444
Enterprise Service Bus | https://localhost:9445
Data Service Server    | https://localhost:9446
Governance Registry    | https://localhost:9447/carbon

If you are using `docker-machine`, replace `localhost` with `docker-machine ip <machine>`.

### Governance Registry Persistance

The [Governance Registry](http://wso2.com/products/governance-registry/) is used to provide a shared governance partition backed by a MySQL database, as documented [here](https://docs.wso2.com/display/ESB490/Governance+Partition+in+a+Remote+Registry). The database `registrydb` is created by the `scripts/mysql/init.sql` script on-start. 

To test the shared governance partition set-up, navigate to the `/_system/governance` registry from any of the web consoles. Add or modify some resources, and expect the changes to be seen in the web consoles of other components. (Some components seem to pick up the changes later.)

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
