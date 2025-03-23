# Oracle Free Kubernetes cluster

## Deploy
```bash
terragrunt run-all apply
```

## Connect to cluster
We have 2 options to connect to the cluster.

### Configure .kube/config
```bash
just configure-oke-kubectl
```
### exported var
```bash
terragrunt output --raw kube_config > ~/.kube/oci.config
export KUBECONFIG=~/.kube/oci.config
```


## Post Install
After install everything some pods are not handled by cilium until restart to fix this.

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

We need to create cluster secrets.

```bash
just create_age_k8s_key <cluster_name>
```
Then update .sops.yaml with the new pubkey and create the secrets.
Create / Update secrets as needed.

Update secrets keys so the new key is authorized to decrypt the secrets.
```bash
just update_secrets_keys
```
Install key into cluster
```bash
just install_k8s_key <cluster_name>
```