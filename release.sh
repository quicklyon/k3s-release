#!/bin/bash

set -ex

base=${1:-./.release}

releasedir=$base
rm -fr $releasedir
mkdir -p $releasedir

get_helm(){
    local helm_ver=v3.10.3
    rm -f /tmp/helm-${helm_ver}-linux-amd64.tar.gz
    rm -rf /tmp/helm && mkdir -p /tmp/helm
    curl -s -L https://get.helm.sh/helm-${helm_ver}-linux-amd64.tar.gz -o /tmp/helm-${helm_ver}-linux-amd64.tar.gz
    tar xzf /tmp/helm-${helm_ver}-linux-amd64.tar.gz -C /tmp/helm  --strip-components=1
    echo "copy helm ${helm_ver}"
    cp -a /tmp/helm/helm ${releasedir}
    chmod +x ${releasedir}/helm
}

get_k3s(){
    local k3s_ver=v1.25.5+k3s2
    curl -s -L https://github.com/rancher/k3s/releases/download/${k3s_ver}/k3s -o ${releasedir}/k3s
    echo "download k3s ${k3s_ver}"
    chmod +x ${releasedir}/k3s
}

get_kubectl(){
  local k8s_ver=v1.25.5
  curl -s -L https://dl.k8s.io/${k8s_ver}/kubernetes-client-linux-amd64.tar.gz -o /tmp/kubernetes-client-${k8s_ver}-linux-amd64.tar.gz
  echo "download k8s ${k8s_ver}"
  tar xzf /tmp/kubernetes-client-${k8s_ver}-linux-amd64.tar.gz -C /tmp --strip-components=1
  cp -a /tmp/client/bin/kubectl ${releasedir}
  chmod +x ${releasedir}/kubectl
}

download(){
  get_k3s
  get_helm
  get_kubectl
}

build(){
  download
  cd ${releasedir}
  tar zcf pkg.tgz `find . -maxdepth 1 | sed 1d`
}

build
