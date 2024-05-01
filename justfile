default_server:="localhost"
default_arch:="x86_64"
default:
  @just --choose

build_bootstrap_iso arch=default_arch:
    nix build -L .#packages.{{arch}}-linux.bootstrap-iso -o build/bootstrap-iso
# User keys

bootstrap_setup profile arch=default_arch:
    ./scripts/bootstrap-nixos.sh -n={{profile}}

bootstrap_apply profile server arch=default_arch:
    nix run github:nix-community/nixos-anywhere -- \
        --kexec "$(nix build --print-out-paths .#packages.{{arch}}-linux.kexec-installer-nixos)/nixos-kexec-installer-{{arch}}-linux.tar.gz" \
        --disk-encryption-keys /tmp/disk.key "$(pwd)/build/bootstrap/{{profile}}/disk.key" \
        --extra-files "$(pwd)/build/bootstrap/{{profile}}" \
        --flake .#{{profile}} \
        "root@{{server}}"

deploy profile server:
    nixos-rebuild switch -L --flake .#{{profile}} --target-host root@{{server}}
create_age_user_key user:
    age-keygen -o "./secrets/key/age_user_{{user}}_key.txt"
    @echo "Key generated at: ./secrets/key/age_user_{{user}}_key.txt"
    @echo "Save this key-file in a safe place!"
    @echo "Now you can just install_user_key <user> <ssh_host> to install this key to the target servers"

install_user_key user server=default_server:
    rsync -arvP --mkpath --perms --chmod=600 ./secrets/key/age_user_{{user}}_key.txt {{user}}@{{server}}:~/.secrets/nix/age_user_key.txt
    

get_age_user_pubkey user:
    @age-keygen -y "./secrets/key/age_user_{{user}}_key.txt"

get_age_user_server_pubkey user server=default_server:
    ssh {{user}}@{{server}} 'cat ~/.secrets/nix/age_user_key.txt'


# Machine keys
machine_age_pubkey server=default_server:
    ssh-keyscan {{server}} | ssh-to-age


# update recipents and rotate data keys
update_secrets_keys:
    find ./secrets -type d -name key -prune -o \( -type f -not -name .gitkeep \) -exec sops updatekeys {} \;
    #find ./secrets -type d -name key -prune -o \( -type f -not -name .gitkeep \) -exec sh -c 'sops -r {} | sponge {}' \;
