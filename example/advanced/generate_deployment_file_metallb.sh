#!/bin/bash

NAMESPACE="smoketest-deployments"

TEMPLATE_FILENAME="smoketestservice-deployment-metallb-template.yml"
NEWFILE_SUFFIX="metallb-deployment.yml"

SERVICENAME=$1
METALLB_IP_ADDR=$2
if [[ -z $SERVICENAME ]]; then
    echo "Usage:"
    echo "generate_deployment_file_metallb.sh <SERVICENAME> <METALLB_IP_ADDR>"
    echo
    echo "Mandatory: <SERVICENAME>"
    echo -e "Optional:  <METALLB_IP_ADDR>, where a valid IP address from your MetalLB pool range is expected.\n    If you omit an IP address the deployment will probably have an IP randomly assigned from the IP Pool specified in the group_vars/all.yml during the deployment."
    echo 
    echo -e "Example:\n    ./generate_deployment_file_metallb.sh myservice 192.168.1.101" 
    exit 1
else
    echo -e "NOTE: If you deployed ingress-nginx with the helm addons option you can generate deployment templates with 'generate_deployment_file_ingress.sh' script instead\n"

    cp -f smoketestservice-deployment-metallb-template.yml "$SERVICENAME-$NEWFILE_SUFFIX"
    sed -i '' "s/TESTNAMESPACE/$NAMESPACE/g"         "$SERVICENAME-$NEWFILE_SUFFIX" && \
    sed -i '' "s/SMOKETESTSERVICE/$SERVICENAME/g"    "$SERVICENAME-$NEWFILE_SUFFIX"

    if [[ $? -eq 0 ]]; then
        echo -e "Deployment file: $SERVICENAME-$NEWFILE_SUFFIX was generated.\n"
        echo -e "Deploy the service with:\n    kubectl apply -f $SERVICENAME-$NEWFILE_SUFFIX\n"
        echo -e "Make sure that you create the namespace first:\n    kubectl apply -f smoketest-deployments-namespace.yml"
    else
        echo "UNKNOWN ERROR!"
        exit 1
    fi
fi

if [[ -z $METALLB_IP_ADDR ]]; then
    sed -i '' "s/annotations:/#annotations:/g"   "$SERVICENAME-$NEWFILE_SUFFIX" && \
    sed -i '' "s/metallb./#metallb./g"           "$SERVICENAME-$NEWFILE_SUFFIX"
    if [[ $? -eq 0 ]]; then
        echo
        echo "NOTE: <METALLB_IP_ADDR> was not specified."
        echo "The deployment will probably have an IP address randomly assigned from the MetalLB pool."
        echo "To view the assigned IP address you can use the:"
        echo "    kubectl get services -n $NAMESPACE"
    fi
else
    # Simple check for a valid IP
    if [[ "$METALLB_IP_ADDR" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$  ]]; then 
        sed -i '' "s/METALLB_POOL_IP_ADDR/$METALLB_IP_ADDR/g" "$SERVICENAME-$NEWFILE_SUFFIX"
    else
        echo "ERROR! Invalid IP Address specified."
        rm -f "$SERVICENAME-$NEWFILE_SUFFIX"
        exit 1
    fi
fi
