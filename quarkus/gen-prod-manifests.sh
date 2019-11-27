#!/bin/bash

if [[ $# -ne 2 ]]; then
  cat <<EOF

ERR: Please provide the API URL and the Namespace of the Prod Cluster as arguments

  ./gen-prod-secret.sh <API_PROD_CLUSTER> <NAMESPACE_PROD_CLUSTER>

EOF
  exit 99
fi

export API_URL=$1
export NAMESPACE=$2

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

cat <<EOF > pipelineresource-prod-cluster.yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: prod-cluster
spec:
  type: cluster
  params:
    - name: name
      value: prod-cluster
    - name: username
      value: pipeline
    - name: namespace
      value: $NAMESPACE
    - name: url
      value: $API_URL
  secrets:
    - fieldName: token
      secretKey: tokenKey
      secretName: cluster-prod-secret
    - fieldName: cadata
      secretKey: cadataKey
      secretName: cluster-prod-secret
EOF

# Reference:
# * https://developer.ibm.com/blogs/define-a-simple-cd-pipeline-with-knative/
