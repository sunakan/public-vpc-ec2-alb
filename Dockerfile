FROM node:14-slim
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
WORKDIR /var/local/app

################################################################################
# aws cdk
################################################################################
RUN npm install --global aws-cdk

################################################################################
# aws cli
# 最新バージョン確認方法
# https://github.com/aws/aws-cli/releases
################################################################################
ENV AWSCLI_VERSION 2.0.54
RUN apt-get update \
  && apt-get install --assume-yes \
    curl \
    unzip \
    git \
    less \
    jq
RUN cd /tmp/ \
  && curl --output "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm --recursive --force /tmp/*
