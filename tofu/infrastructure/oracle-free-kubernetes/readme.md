# Oracle Free Kubernetes cluster

## Deploy
```bash
terragrunt run-all apply
```

## Connect to cluster
```bash
terragrunt output --raw kube_config > ~/.kube/oci.config
export KUBECONFIG=~/.kube/oci.config 
k9s
```


## Post Install
1. After install everything some pods are not handled by cilium until restart to fix this.

```bash
curl -sLO https://raw.githubusercontent.com/cilium/cilium/master/contrib/k8s/k8s-unmanaged.sh
chmod +x k8s-unmanaged.sh
./k8s-unmanaged.sh

# delete pods listed in the output
kubectl delete pod -n kube-system kube-dns-autoscaler-5cc689bf64-flmr6

# check all is fine
cilium status 

# delete flannel CNI
kubectl delete ds -n kube-system kube-flannel-ds

# delete kubeproxy
kubectl delete ds -n kube-system kube-proxy
```

2. We need to create cluster secrets.

```bash
just create_age_k8s_key <cluster_name>
```
Then update .sops.yaml with the new pubkey and create the secrets
within `/gitops/clusters/<cluster_name>/secrets/`