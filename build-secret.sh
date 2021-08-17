#!/bin/bash
# --------------------------------------------------------------------------------------------------------
# Name : Create Edge Access Secret for use in CI/CD Pipeline in Development Cluster
#
# Log into Edge Cluster and run this script
# The script expects two arguments, Org ID and API
#
# Once Secret has been create apply the secret to you development project/namespace
#
# Author : Matthew Perrins mjperrin@us.ibm.com, Steve.Cotugno@us.ibm.com
# Update:  Updated to support EAM V4.2.  
#
# Edge API Key is required for publishing to EAM.  For details see https://www.ibm.com/docs/en/edge-computing/4.2?topic=installation-creating-your-api-key
# --------------------------------------------------------------------------------------------------------
#
# input validation

if [ -z "$2" ]; then
    echo -e "\nPlease call '$0 <Org ID> <API KEY>' to run this command!\n"
    exit 1
fi

export HZN_ORG_ID=$1
export EDGE_APIKEY=$2

# Extract the Core meta data for
export MGM_HUB_INGRESS=$(oc get cm management-ingress-ibmcloud-cluster-info -n ibm-edge -o jsonpath='{.data.cluster_ca_domain}')
export HZN_EXCHANGE_URL=https://${MGM_HUB_INGRESS}/edge-exchange/v1
export HZN_EXCHANGE_USER_AUTH=iamapikey:${EDGE_APIKEY}
export HZN_FSS_CSSURL=https://${MGM_HUB_INGRESS}/edge-css/


# Extract the Certificate Authority Certificate
oc get secret management-ingress-ibmcloud-cluster-ca-cert -n ibm-common-services  -o  jsonpath="{.data['ca\.crt']}" | base64 --decode > ./icp-ca.crt

# Need to add this one below when the above line is working
# --from-file=HZN_CERTIFICATE=./icp-ca.crt

# Create the Secret
oc create secret generic edge-access \
  --from-literal=HZN_ORG_ID=$HZN_ORG_ID \
  --from-literal=APIKEY=$EDGE_APIKEY \
  --from-literal=HZN_EXCHANGE_USER_AUTH=$HZN_EXCHANGE_USER_AUTH \
  --from-literal=HZN_EXCHANGE_URL=$HZN_EXCHANGE_URL \
  --from-literal=HZN_FSS_CSSURL=$HZN_FSS_CSSURL \
  --from-file=HZN_CERTIFICATE=./icp-ca.crt \
  -o yaml --dry-run | \
oc label -f - --dry-run --local -o yaml --local \
  group=catalyst-tools \
  grouping=garage-cloud-native-toolkit  > edge-access-secret.yaml

echo "Completed creating the edge-access-security.yaml ..."