#!/bin/bash

read -r -d '' KUBECONFIG_TEMPLATE << EOM
apiVersion: v1
clusters:
- cluster:
    server: __CLUSTER_ENDPOINT__
    certificate-authority-data: __CERTIFICATE_AUTHORITY_DATA__
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "__CLUSTER_NAME__"
EOM

function get_cluster_data() {
  local CLUSTER_NAME=$1
  local QUERY=$2 
 
  local DATA=$(aws eks describe-cluster --region ${REGION} --name ${CLUSTER_NAME} --query ${QUERY})
  
  if [ $? -ne 0 ]; then
    echo "error! exiting."
    exit 1
  fi 
  
  echo ${DATA}
}

function main() {
  CLUSTER_NAME=${1:-$CLUSTER_NAME}
  REGION=${REGION:-"us-east-1"}

  if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    echo "Env var AWS_ACCESS_KEY_ID not set."
    exit 1
  fi

  if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo "Env var AWS_SECRET_ACCESS_KEY not set."
    exit 1
  fi
  
  if [ -z "${CLUSTER_NAME}" ]; then
    echo "Env var CLUSTER_NAME not set or passed in as an argument."
    exit 1
  fi

  if [ ! -z "${ROLE_ARN}" ]; then
    read -r -d '' ROLE_ARN_ARGS << EOM
        - "-r"
        - "${ROLE_ARN}"
EOM
    KUBECONFIG_TEMPLATE="${KUBECONFIG_TEMPLATE}\n        ${ROLE_ARN_ARGS}"
  fi
  
  local CLUSTER_ENDPOINT=$(get_cluster_data ${CLUSTER_NAME} cluster.endpoint)
  local CERTIFICATE_AUTHORITY_DATA=$(get_cluster_data ${CLUSTER_NAME} cluster.certificateAuthority.data)

  echo -e "${KUBECONFIG_TEMPLATE}" | sed \
    -e "s@__CLUSTER_ENDPOINT__@$CLUSTER_ENDPOINT@g" \
    -e "s@__CERTIFICATE_AUTHORITY_DATA__@$CERTIFICATE_AUTHORITY_DATA@g" \
    -e "s@__CLUSTER_NAME__@$CLUSTER_NAME@g"
}

main ${@}
