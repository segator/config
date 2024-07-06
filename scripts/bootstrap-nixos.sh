#!/usr/bin/env bash
set -eo pipefail

target_hostname=""
target_destination=""
target_user="root"
persist_dir="/persist"

# terminal output coloring
function red() {
    echo -e "\x1B[31m[!] $1 \x1B[0m"
    if [ -n "${2}" ]; then
        echo -e "\x1B[31m[!] $($2) \x1B[0m"
    fi
}

function green() {
    echo -e "\x1B[32m[+] $1 \x1B[0m"
    if [ -n "${2}" ]; then
        echo -e "\x1B[32m[+] $($2) \x1B[0m"
    fi
}

function yellow() {
    echo -e "\x1B[33m[*] $1 \x1B[0m"
    if [ -n "${2}" ]; then
        echo -e "\x1B[33m[*] $($2) \x1B[0m"
    fi
}

# confirmation helper
function yes_or_no {
    while true; do
        read -rp "$* [y/n]: " yn
        case $yn in
        [Yy]*) return 0 ;;
        [Nn]*)
            echo "Aborted"
            return 1
            ;;
        esac
    done
}

# help function
function help_and_exit() {
    echo
    echo "Remotely installs NixOS on a target machine using this nix-config."
    echo
    echo "USAGE: $0 -n=<target_hostname>"
    echo
    echo "ARGS:"
    echo "  -n=<target_hostname>      specify target_hostname of the target host to deploy the nixos config on."
    echo
    echo "OPTIONS:"
    echo "  --debug                   Enable debug mode."
    echo "  -h | --help               Print this help."
    exit 0
}

get_password() {
    local password1 password2
    read -s -p "Enter your disk encryption key: " password1
    echo
    read -s -p "Confirm: " password2
    echo

    # Check if passwords match
    if [ "$password1" != "$password2" ]; then
        echo "Passwords do not match. Please try again."
        get_password
    else
        password="$password1"
    fi
}

tang_server_input() {
    ask_for_tang_server_url
    ask_for_tang_thp    
}

# Function to prompt the user for Tang Server URL
ask_for_tang_server_url() {
    while true; do
        read -p "Provide Tang Server URL: " tang_url
        if [[ $tang_url =~ ^https?:// ]]; then
            break
        else
            echo "Invalid URL $tang_url. Please provide a valid Tang Server URL."
        fi
    done
}

ask_for_tang_thp(){
    read -p "Provide Tang Fingerprint (thp): " tang_thp
}

# Handle options
while [[ $# -gt 0 ]]; do
    case "$1" in
    -n=*)
        target_hostname="${1#-n=}"
        ;;
    --debug)
        set -x
        ;;
    -h | --help) help_and_exit ;;
    *)
        echo "Invalid option detected."
        help_and_exit
        ;;
    esac
    shift
done

# Validate required options
if [ -z "${target_hostname}" ]; then
    red "ERROR: -n, required"
    echo
    help_and_exit
fi

# Create a temp directory for generated host keys
temp="$(pwd)/build/bootstrap/$target_hostname"
mkdir -p "$temp"

green "Preparing a new ssh_host_ed25519_key pair for $target_hostname."

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/$persist_dir/system/etc/ssh"
install -d -m755 "$temp/$persist_dir/system/initrd"

# Generate host keys without a passphrase
ssh-keygen -t ed25519 -f "$temp/$persist_dir/system/etc/ssh/ssh_host_ed25519_key" -C "$target_user@$target_hostname" -N ""
ssh-keygen -t ed25519 -f "$temp/$persist_dir/system/initrd/ssh_host_ed25519_key" -C "$target_user@$target_hostname" -N ""

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/$persist_dir/system/etc/ssh/ssh_host_ed25519_key"

# Ask the user if they want to enable encryption
encryption_enabled=false
if yes_or_no "Do you want to enable disk encryption?"; then
    encryption_enabled=true
fi

# Create a file indicating the encryption status
encryption_status_file="$temp/encryption"
echo "Encryption enabled: $encryption_enabled" > "$encryption_status_file"

if $encryption_enabled; then
    green "Preparing root disk encryption"

    # Prompt the user to enter the password
    get_password

    # Specify the file to save the password
    disk_key_file="$temp/disk.key"

    # Save the password to a file
    echo "$password" > "$disk_key_file"

    tang_server_input
    echo $password | clevis encrypt tang "{\"url\": \"$tang_url\", \"thp\": \"$tang_thp\"}" > "${disk_key_file}.jwe"
    echo "Tang Key created: ${disk_key_file}.jwe"
fi

green "Generating an age key based on the new ssh_host_ed25519_key."

age_key=$(cat "$temp/$persist_dir/system/etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age)

if grep -qv '^age1' <<<"$age_key"; then
    echo "The result from generated age key does not match the expected format."
    echo "Result: $age_key"
    echo "Expected format: age10000000000000000000000000000000000000000000000000000000000"
    exit 1
fi

green "Please update your .sops.yaml file with the new host age key: "
echo $age_key

read -rp "Press any key to continue: "
just update_secrets_keys
