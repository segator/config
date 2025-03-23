#!/usr/bin/env bash

kubectl delete ds -n kube-system kube-flannel-ds
kubectl delete ds -n kube-system kube-proxy

curl -sLO https://raw.githubusercontent.com/cilium/cilium/master/contrib/k8s/k8s-unmanaged.sh
chmod +x k8s-unmanaged.sh

# Run the script and capture its output
output=$(./k8s-unmanaged.sh 2>&1)

# Parse the output and extract pod names and namespaces
while read -r line; do
  if [[ $line == "Skipping pods with host networking enabled or with status not in Running or Pending phase..." ]]; then
    continue
  fi

  if [[ $line =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+ ]]; then
      namespace_pod=$(echo "$line" | tr -d '\r')

      namespace=$(echo "$namespace_pod" | cut -d'/' -f1)
      pod_name=$(echo "$namespace_pod" | cut -d'/' -f2)

      echo "Deleting pod: $namespace/$pod_name"
      kubectl delete pod "$pod_name" -n "$namespace" --force --grace-period=0
  fi
done <<< "$output"
echo "Script completed."
