#!/bin/bash

if [[ $# -ne 2 ]]; then
  cat <<EOF

ERR: Please provide the API URL and the Namespace of the Prod Cluster as arguments

  ./gen-prod-secret.sh <NAMESPACE_PROD_CLUSTER>

EOF
  exit 99
fi

export NAMESPACE=$1

SERVICE_ACCOUNT_SECRET_NAME=$(oc get serviceaccount/pipeline -n ${NAMESPACE} -o jsonpath='{.secrets[0].name}')
CA_DATA=$(kubectl get secret/$SERVICE_ACCOUNT_SECRET_NAME -n ${NAMESPACE} -o jsonpath="{.data.ca\.crt}")
TOKEN=$(kubectl get secret/$SERVICE_ACCOUNT_SECRET_NAME -n ${NAMESPACE} -o jsonpath='{.data.token}')

cat <<EOF > pipelineresource-prod-cluster-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cluster-prod-secret
type: Opaque
data:
  cadataKey: $CA_DATA
  tokenKey: $TOKEN
EOF

# Reference:
# * https://developer.ibm.com/blogs/define-a-simple-cd-pipeline-with-knative/
