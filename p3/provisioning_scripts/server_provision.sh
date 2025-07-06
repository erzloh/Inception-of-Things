#!/bin/bash

set -euo pipefail

# Install basic dependencies
apt-get update
apt-get install -y curl

# Install Docker
curl -fsSL https://get.docker.com | bash

# installer K3d
curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install kubectl
curl -fsSLO "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Create the K3d cluster with the right ports exposed
k3d cluster create iot42-cluster \
    -p "8080:80@loadbalancer"

# Create namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Install Argo CD in the cluster under the argocd namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/install.yaml

kubectl -n argocd patch deployment argocd-server \
--type='json' \
-p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--insecure"}]'

# Apply the ingress controller for Argo CD
kubectl apply -f /vagrant/confs/argocd-iot42-ingress.yaml

# Apply the Argo CD Application
kubectl apply -f /vagrant/confs/argocd-iot42-app.yaml