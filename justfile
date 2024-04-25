default_server:="localhost"
default:
  @just --choose

build_bootstrap_iso:
    nix build -L .#nixosConfigurations.bootstrap-iso.config.system.build.isoImage -o build/bootstrap-iso
# User keys

remote_bootstrap profile server:
    #!/usr/bin/env sh
    temp=$(mktemp -d)
    # Function to prompt the user for password entry securely
    get_password() {
        local password1 password2
        read -s -p "Enter your disk encryption key: " password1
        echo
        read -s -p "Confirm:" password2
        echo

        # Check if passwords match
        if [ "$password1" != "$password2" ]; then
            echo "Passwords do not match. Please try again."
            get_password
        else
            password="$password1"
        fi
    }

    # Prompt the user to enter the password
    get_password

    # Specify the file to save the password
    disk_key_file="$temp/disk.key"

    # Save the password to a file
    echo "$password" > "$disk_key_file" 

    nix run github:numtide/nixos-anywhere -- \
    --disk-encryption-keys $disk_key_file /tmp/disk.key \
    --extra-files "$temp" \
    --flake .#{{profile}} \
    root@{{server}}
    

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
    find ./secrets -type d -name key -prune -o \( -type f -not -name .gitkeep \) -exec sh -c 'sops -r {} | sponge {}' \;
