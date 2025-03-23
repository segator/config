#!/bin/bash

set -e
set -o pipefail

# Function to get all CiliumEndpoints (CEPs)
function all_ceps {
  kubectl get cep --all-namespaces -o json | jq -r '.items[].metadata | .namespace + "/" + .name'
}

# Function to get all running/pending pods excluding those with host networking
function all_pods {
  kubectl get pods --all-namespaces -o json | jq -r '.items[] | select((.status.phase=="Running" or .status.phase=="Pending") and (.spec.hostNetwork==true | not)) | .metadata | .namespace + "/" + .name'
}

# Get the list of unmanaged pods
unmanaged_pods=$(comm -23 <(all_pods | sort) <(all_ceps | sort))

# Delete the unmanaged pods
echo "$unmanaged_pods" | xargs -I {} bash -c 'kubectl delete pod -n $(echo {} | cut -d"/" -f1) $(echo {} | cut -d"/" -f2) --force --grace-period=0'

# Delete DaemonSets if they exist
if kubectl get ds -n kube-system kube-flannel-ds &> /dev/null; then
  kubectl delete ds -n kube-system kube-flannel-ds
fi

if kubectl get ds -n kube-system kube-proxy &> /dev/null; then
  kubectl delete ds -n kube-system kube-proxy
fi