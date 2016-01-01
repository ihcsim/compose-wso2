#!/bin/bash

export WSO2_GATEWAY=192.168.99.100

export APIM_VERSION=1.9.1
export DSS_VERSION=3.5.0
export ESB_VERSION=4.9.0
export GREG_VERSION=5.1.0
export IS_VERSION=5.0.0

export MYSQL_VERSION=5.7.10
export MYSQL_ROOT_PASSWORD=password

find conf -type f -name '*.xml' -exec sed -i "" "s/\$WSO2_GATEWAY/$WSO2_GATEWAY/g" {} \;
