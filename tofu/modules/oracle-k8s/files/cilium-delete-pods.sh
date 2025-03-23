#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Return the exit status of the last command in the pipe that failed

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