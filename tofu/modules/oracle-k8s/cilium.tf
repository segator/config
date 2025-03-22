locals {
  cilium_values = templatefile("${path.module}/files/helm-cilium-values.tpl.yaml",
    {
      loadBalancerIP = local.nlb_public_ip
      insecureNodePort = local.ports[index(local.ports[*].name,"http")].backendPort
      secureNodePort = local.ports[index(local.ports[*].name,"https")].backendPort
    }
  )
}
resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = "1.17.2"
  create_namespace = true
  wait = true
  wait_for_jobs = true

  values = [local.cilium_values]
}

resource "null_resource" "delete_cilium_pods" {
  depends_on = [local_sensitive_file.kubeconfig]
  # Use a local-exec provisioner to run the shell script.
  provisioner "local-exec" {
    interpreter = ["/bin/env", "bash", "-c"]
    command = <<-EOT
      # Download the k8s-unmanaged.sh script
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
    EOT

    environment = {
      KUBECONFIG = local_sensitive_file.kubeconfig.filename
    }

  }
}