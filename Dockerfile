FROM python:alpine

ENV EKS_VERSION="1.10.3/2018-07-26"
ENV HELM_VERSION="v2.9.1"

RUN apk add --no-cache bash curl && \
  pip install awscli && \
  wget -O /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/${EKS_VERSION}/bin/linux/amd64/kubectl && \
  wget -O /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/${EKS_VERSION}/bin/linux/amd64/aws-iam-authenticator && \
  wget -qO - https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip 1 linux-amd64/helm -C /usr/local/bin/ && \
  chmod +x /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/aws-iam-authenticator && \
  chmod +x /usr/local/bin/helm

ADD get_eks_kubeconfig.sh /usr/local/bin

CMD /usr/local/bin/get_eks_kubeconfig.sh
