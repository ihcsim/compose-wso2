#!/bin/bash

# This script defines all the environmental variables used in this project.
# It also replaces the inlined parameters in some configuration file templates with the appropriate values.

export WSO2_GATEWAY=192.168.99.100

export IS_VERSION=5.0.0
export IS_HTTPS_PORT=9443
export IS_HTTP_PORT=9763
export IS_SAML_SSO_URL=https://$WSO2_GATEWAY:$IS_HTTPS_PORT/samlsso

export APIM_VERSION=1.9.1
export APIM_HTTPS_PORT=9444
export APIM_HTTP_PORT=9764
export APIM_SSO_SERVICE_PROVIDER=service-provider-apim
export APIM_SSO_ACS_URL=https://$WSO2_GATEWAY:$APIM_HTTPS_PORT/acs

export ESB_VERSION=4.9.0
export ESB_HTTPS_PORT=9445
export ESB_HTTP_PORT=9765
export ESB_SSO_SERVICE_PROVIDER=service-provider-esb
export ESB_SSO_ACS_URL=https://$WSO2_GATEWAY:$ESB_HTTPS_PORT/acs

export DSS_VERSION=3.5.0
export DSS_HTTPS_PORT=9446
export DSS_HTTP_PORT=9766
export DSS_SSO_SERVICE_PROVIDER=service-provider-dss
export DSS_SSO_ACS_URL=https://$WSO2_GATEWAY:$DSS_HTTPS_PORT/acs

export GREG_VERSION=5.1.0
export GREG_HTTPS_PORT=9447
export GREG_HTTP_PORT=9767
export GREG_SSO_SERVICE_PROVIDER=service-provider-greg
export GREG_SSO_ACS_URL=https://$WSO2_GATEWAY:$GREG_HTTPS_PORT/acs
export GREG_REMOTE_URL=https://$WSO2_GATEWAY:$GREG_HTTPS_PORT/registry

export MYSQL_VERSION=5.7.10
export MYSQL_ROOT_PASSWORD=password

# This function will copy the conf/common/authenticators.xml template to each component with the inlined parameters replaced
# with appropriate values for each component.
authenticatorConfig(){
  basedir=`basename "$1"`

  if [ "$basedir" != "common" ] && [ "$basedir" != "mysql" ] && [ "$basedir" != "wso2is" ]; then
    cp conf/common/authenticators.xml conf/$basedir/authenticators.xml
    case "$basedir" in
      wso2am )
        sp=$APIM_SSO_SERVICE_PROVIDER
        acs_url=$APIM_SSO_ACS_URL
        ;;
      wso2esb )
        sp=$ESB_SSO_SERVICE_PROVIDER
        acs_url=$ESB_SSO_ACS_URL
        ;;
      wso2dss )
        sp=$DSS_SSO_SERVICE_PROVIDER
        acs_url=$DSS_SSO_ACS_URL
        ;;
      wso2greg )
        sp=$GREG_SSO_SERVICE_PROVIDER
        acs_url=$GREG_SSO_ACS_URL
        ;;
    esac
    sed -i "" \
      -e "s/\$SSO_SERVICE_PROVIDER/$sp/g" \
      -e "s|\$ACS_URL|$acs_url|g" \
      -e "s|\$IS_SAML_SSO_URL|$IS_SAML_SSO_URL|g" \
      conf/$basedir/authenticators.xml
  fi
}

for dir in conf/*; do
  if [ -d "$dir" ]; then
    authenticatorConfig "$dir"
  fi
done

find conf -type f -name '*.xml' -exec sed -i "" \
  -e "s/\$WSO2_GATEWAY/$WSO2_GATEWAY/g" \
  -e "s/\$APIM_SSO_SERVICE_PROVIDER/$APIM_SSO_SERVICE_PROVIDER/g" \
  -e "s|\$APIM_SSO_ACS_URL|$APIM_SSO_ACS_URL|g" \
  -e "s/\$ESB_SSO_SERVICE_PROVIDER/$ESB_SSO_SERVICE_PROVIDER/g" \
  -e "s|\$ESB_SSO_ACS_URL|$ESB_SSO_ACS_URL|g" \
  -e "s/\$DSS_SSO_SERVICE_PROVIDER/$DSS_SSO_SERVICE_PROVIDER/g" \
  -e "s|\$DSS_SSO_ACS_URL|$DSS_SSO_ACS_URL|g" \
  -e "s/\$GREG_SSO_SERVICE_PROVIDER/$GREG_SSO_SERVICE_PROVIDER/g" \
  -e "s|\$GREG_SSO_ACS_URL|$GREG_SSO_ACS_URL|g" \
  -e "s|\$GREG_REMOTE_URL|$GREG_REMOTE_URL|g" \
  {} \;
