default_server:="localhost"
default_arch:="x86_64"
default_homeconfiguration:=`echo $(whoami)@$(hostname)`
default:
  @just -l


build_bootstrap_iso arch=default_arch:
    nix build -L .#packages.{{arch}}-linux.bootstrap-iso -o build/bootstrap-iso
# User keys

bootstrap_setup profile arch=default_arch:
    ./scripts/bootstrap-nixos.sh -n={{profile}}

# Todo add back kexec in nixos-anywhere when this bug solved https://github.com/nix-community/nixos-images/issues/249  --kexec "$$(nix build --print-out-paths .#packages.{{arch}}-linux.kexec-installer-nixos)/nixos-kexec-installer-{{arch}}-linux.tar.gz"
bootstrap_apply profile server arch=default_arch:
	encryption_status_file="$(pwd)/build/bootstrap/{{profile}}/encryption"; \
	if [ -f "$$encryption_status_file" ] && grep -q "true" "$$encryption_status_file"; then \
		disk_encryption_keys="--disk-encryption-keys /tmp/disk.key $(pwd)/build/bootstrap/{{profile}}/disk.key --disk-encryption-keys /tmp/disk.key.jwe $(pwd)/build/bootstrap/{{profile}}/disk.key.jwe"; \
	else \
		disk_encryption_keys=""; \
	fi; \
	nix run github:nix-community/nixos-anywhere -- \
		--extra-files "$(pwd)/build/bootstrap/{{profile}}" \
		--flake .#{{profile}} \
		"root@{{server}}"

deploy server:
    deploy --auto-rollback false --skip-checks .#{{server}}

apply_home homeconfiguration=default_homeconfiguration:
    nh home switch -c {{homeconfiguration}} .
create_age_user_key user:
    age-keygen -o ~/.secrets/user_{{user}}_key.txt
    @echo "Key generated at: ~/.secrets/user_{{user}}_key.txt"
    @echo "Save this key-file in a safe place!"
    @echo "Now you can just install_user_key <user> <ssh_host> to install this key to the target servers"

# Create a k8s age key
create_age_k8s_key cluster_name:
    age-keygen -o ~/.secrets/k8s_{{cluster_name}}_key.txt
    @echo "Key generated at: ~/.secrets/k8s_{{cluster_name}}_key.txt"
    @echo "Now you can update your k8s secrets in .sops.yaml and run just update_secrets_keys"

#Install a k8s age key, ensure to create_age_k8s_key before running this
install_k8s_key cluster_name:
   kubectl describe ns flux-system || kubectl create ns flux-system
   kubectl create secret generic flux-sops-agekey \
   --namespace flux-system \
   --from-literal=age.agekey="$(cat ~/.secrets/k8s_{{cluster_name}}_key.txt)"

install_user_key user server=default_server:
    rsync -arvP --mkpath --perms --chmod=600 ~/.secrets/user_{{user}}_key.txt {{user}}@{{server}}:~/.secrets/nix/age_user_key.txt
    

get_age_user_pubkey user:
    @age-keygen -y "~/.secrets/user_{{user}}_key.txt"

get_age_user_server_pubkey user server=default_server:
    ssh {{user}}@{{server}} 'cat ~/.secrets/nix/age_user_key.txt'


# Machine keys
machine_age_pubkey server=default_server:
    ssh-keyscan {{server}} | ssh-to-age


# update recipents and rotate data keys
update_secrets_keys:
    find ./secrets -type d -name key -prune -o \( -type f -not -name .gitkeep \) -exec sops updatekeys {} \;
    #find ./secrets -type d -name key -prune -o \( -type f -not -name .gitkeep \) -exec sh -c 'sops -r {} | sponge {}' \;


# Configure kubectl with OCI cluster credentials
configure-oke-kubectl:
    #!/usr/bin/env bash
    cd tofu/infrastructure/oracle-free-kubernetes/01-oracle-k8s
    CLUSTER_ENDPOINT=$(terragrunt output -raw k8s_cluster_endpoint)
    CLUSTER_CA_CERT=$(terragrunt output -raw k8s_cluster_ca_certificate)
    CLUSTER_ID=$(terragrunt output -raw k8s_cluster_id)
    CLUSTER_NAME=$(terragrunt output -raw cluster_name)
    CA_PATH=~/.kube/${CLUSTER_NAME}.pem

    kubectl config set-cluster ${CLUSTER_NAME} \
        --server=${CLUSTER_ENDPOINT} \
        --certificate-authority=${CA_PATH}
    kubectl config set-credentials ${CLUSTER_NAME}-user \
        --exec-api-version=client.authentication.k8s.io/v1beta1 \
        --exec-command=oci \
        --exec-arg=ce \
        --exec-arg=cluster \
        --exec-arg=generate-token \
        --exec-arg=--cluster-id \
        --exec-arg=${CLUSTER_ID}
    kubectl config set-context ${CLUSTER_NAME} \
        --cluster=${CLUSTER_NAME} \
        --user=${CLUSTER_NAME}-user
    kubectl config use-context ${CLUSTER_NAME}
    echo "${CLUSTER_CA_CERT}" > $CA_PATH