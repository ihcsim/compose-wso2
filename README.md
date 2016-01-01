## compose-wso2

compose-wso2 sets up a collection of dockerized WSO2 components with a shared governance registry and SSO capability.

### Description

These are the components included:

1. API Manager
2. Data Service Server
3. Enterprise Service Bus
4. Governance Registry
5. Identity Server

Before you get started with a `docker-compose up`, note that:

1. The WSO2 container images are quite large, ranging from 750MB to a whooping 1.0GB.
2. The first run of `docker-compose up` takes a few minutes as the service images are pulled from my AWS S3 buckets, and the Governance Registry is started with the `-Dsetup` flag in order to initialize all the database tables. Try run `docker-compose pull` prior to running `docker-compose up`.
3. This project utilizes [Compose's networking feature](https://docs.docker.com/compose/networking/) to facilitate inter-containers networking communication.
4. To support [web browser-based SSO with WSO2 Identity Server](https://docs.wso2.com/display/IS510/Configuring+SAML2+Single-Sign-On+Across+Different+WSO2+Products), a new entry for the Identity Server hostname (`wso2identity`) must be added to your `/etc/hosts` file. Refer to the [Usage](#usage) section for more information.
5. In the rest of this README, the `$DOCKER_HOST_IP` variable refers either to the value of `docker-machine ip <machine>` if you are using Docker machine, or just `localhost` if you aren't using Docker machine.

### Usage

1. Set up the default environmental variables and change the `WSO2_GATEWAY` variable to your `$DOCKER_HOST_IP`: `source scripts/env.bash`
2. Update your `/etc/hosts` file with the following line: `<$WSO2_GATEWAY> wso2identity` where `$WSO2_GATEWAY` has the same value as defined in your `scripts/env.bash` script.
3. Pull services: `docker-compose pull <service>`
4. Run services: `docker-compose -p wso2 --x-networking up <service>`
5. Scale services: `docker-compose -p wso2 scale <service=counts>`
6. View logs: `docker-compose -p wso2 logs <service>`

### Web Admin Consoles

The exposed ports of each component can be changed using the `scripts/env.bash` script.

Components             | URL
---------------------- | -----------------------------
Identity Server        | https://$DOCKER_HOST_IP:9443
API Manager            | https://$DOCKER_HOST_IP:9444
Enterprise Service Bus | https://$DOCKER_HOST_IP:9445
Data Service Server    | https://$DOCKER_HOST_IP:9446
Governance Registry    | https://$DOCKER_HOST_IP:9447/carbon

### Governance Registry Persistance

The [Governance Registry](http://wso2.com/products/governance-registry/) is used to provide a shared governance partition backed by a MySQL database, as documented [here](https://docs.wso2.com/display/ESB490/Governance+Partition+in+a+Remote+Registry). The database `registrydb` is created by the `scripts/mysql/greg-init.sql` script on-start. 

To test the shared governance partition set-up, navigate to the `/_system/governance` registry from any of the web consoles. Add or modify some resources, and expect the changes to be seen in the web consoles of other components. Note that caching is disabled in the `registry.xml` file of each component.

There are two others adjustments I had to make to get this to work:

1. Override the default MySQL `sql-mode` using the `conf/mysql/my.cnf` script to remove the [`NO_ZERO_IN_DATE`](http://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_zero_in_date) and [`NO_ZERO_DATE`](http://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_zero_date) restrictions. WSO2 uses `DEFAULT 0` in some of their timestamp queries.
2. Disable SSL by setting the `useSSL` parameter in the JDBC connection string as seen in the `conf/<component>/master-datasources.xml` scripts.

### Single Sign-On

The [Identity Server](http://wso2.com/products/identity-server/) is configured to support web browser-based SSO across all the components based on the steps described [here](https://docs.wso2.com/display/IS510/Configuring+SAML2+Single-Sign-On+Across+Different+WSO2+Products). A MySQL database is used as the [backing data source to store registry and user manager data](https://docs.wso2.com/display/IS510/Setting+up+MySQL). The database `identitydb` is created by the `scripts/mysql/is-init.sql` script on-start.

Instead of defining the service provider for each component via the administrator console, I specified them in the `sso-idp-config.xml` file in accordance to this [example](https://docs.wso2.com/display/IS510/Configuring+a+SP+and+IdP+Using+Configuration+Files). There is an issue with logout where the Identity Server throws an `ERROR {org.wso2.carbon.identity.sso.saml.processors.LogoutRequestProcessor} -  No Established Sessions corresponding to Session Indexes provided.` exception.

Since I am using Docker machine, I have to add the Identity Server hostname (`wso2identity`) to my `/etc/hosts` file. Refer to [Usage](#usage) section on the updates necessary for the `/etc/hosts` file. Otherwise, by default, all the Identity Server SSO web applications will redirect SAML requests back to `localhost`.

The following is a list of SSO-related TODOs:

1. Fix logout issue.
2. Replace the default embedded LDAP server with a Docker container as the primary user store.

### Supported Environmental Variables

The default versions and port numbers of the WSO2 components, MySQL credentials and other environmental variables are defined in the `scripts/env.bash` script.

The following is the list of environmental variables that you will need to change to cater to your environment:

Variables           | Description
------------------- | --------------------------------
WSO2_GATEWAY        | This should be set to either the IP address of your Docker machine, or `localhost` if you aren't using Docker machine.
APIM_VERSION        | Version of the API Manager
APIM_HTTPS_PORT     | Exposed HTTPS port of the API Manager
APIM_HTTP_PORT      | Exposed HTTP port of the API Manager
DSS_VERSION         | Version of the Data Service Server
DSS_HTTPS_PORT      | Exposed HTTPS port of the Data Service Server
DSS_HTTP_PORT       | Exposed HTTP port of the Data Service Server
ESB_VERSION         | Version of the Enterprise Service Bus
ESB_HTTPS_PORT      | Exposed HTTPS port of the Enterprise Service Bus
ESB_HTTP_PORT       | Exposed HTTP port of the Enterprise Service Bus
GREG_VERSION        | Version of the Governance Registry
GREG_HTTPS_PORT     | Exposed HTTPS port of the Governance Registry
GREG_HTTP_PORT      | Exposed HTTPS port of the Governance Registry
IS_VERSION          | Version of the Identity Server
IS_HTTPS_PORT       | Exposed HTTPS port of the Identity Server
IS_HTTP_PORT        | Exposed HTTP port of the Identity Server
MYSQL_VERSION       | Version of the MySQL database
MYSQL_ROOT_PASSWORD | MySQL root password

### Override MySQL Configurations

The default MySQL configurations can be overridden by adding custom configuration files, suffixed with the `.cnf` extension, to the `conf/mysql` folder. For more information, see the MySQL official repository on [dockerhub](https://hub.docker.com/_/mysql/).
