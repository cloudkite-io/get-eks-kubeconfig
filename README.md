This is a docker image that generates an AWS Elastic Kubernetes Service kube-config file, including
kubectl, aws-iam-authenticator, and helm binaries that should work with AWS.

  * kubectl
  * aws-iam-authenticator
  * helm

# Purpose
This image can be used anywhere one needs to interact with a cluster running EKS. 
An example is a part of a Google Cloud Builder build step.


# Usage
Build docker image, then run with the following environment variables:

  * AWS_ACCESS_KEY_ID
  * AWS_SECRET_ACCESS_KEY
  * CLUSTER_NAME
  * REGION (optional; defaults to us-east-1)
  * ROLE_ARN (optional)


## Example

    docker build -t get-eks-kubeconfig . 
    docker run \
      -e AWS_ACCESS_KEY_ID=<my access id> \
      -e AWS_SECRET_ACCESS_KEY=<my secret key> \
      -e CLUSTER_NAME=<my cluster name> \
      -e ROLE_ARN=<my role arn> \
      get-eks-kubeconfig


One can use this image to write the kubeconfig file to disk, setting KUBECONFIG to the file path.

Then, tools such as kubectl and helm can be used to interact with the EKS cluster.
