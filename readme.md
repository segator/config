# Segator Config

This repo contains segator machines configuration.

## Get Started
ensure to have **nix** installed and `cd` into this cloned repo


then, execute any action within
```sh
nix develop
```

## NixOS deploy
do a normal nixos installation, check the code to understand the folder structure
copy the hardware nixos file into the host file and modify whatever you need.
```sh
nixos-rebuild switch --flake .#<host>
```

If secrets are required on this host, ensure to follow all secret managment and rexecute nixos-rebuild


## home-manager deploy
ensure to install home-manager first following standard guide depending your OS

check the code to understand the folder structure.

modify whatever you need.

Ensure to open a terminal in the host and with the user you want to apply the home-manager configuration.


```sh
home-manager switch --flake .
```

if requires secrets you would need to execute this first time and each time you changes secrets

```sh
# if first time installing home manager
systemctl --user start sops-nix.service
# or 
systemctl --user restart sops-nix.service
```

## Secret Managment

If this is the first time deploying this flake, you need to ensure you have your secrets encrypted.

We encrypt secrets using machine keys and user key, so you can define what secrets a machine can access as well as the user in each machine.



1. **create a user key**

```sh
just create_age_user_key <username>
```
The generated key is in git ignored so won't be pushed and is stored at `./secrets/key/`.

Remember to save this user key in a safe place!

2. **install user key to server**
now you need to deploy your user key to the target server.
next command uses ssh to deploy the key but you can do it by any other method.

```sh
just install_user_key <username> <server>
```

3. **retrieve public user key**
If you created the user key in this machine then you can execute.

```sh
just get_age_user_pubkey <username>
```
Otherwise you can retrieve the public key executing this command extracting the key from the target server

```sh
just get_age_user_server_pubkey <username> <server>
```

5. **retrieve server public key**
We also need the public key of servers in case we need secrets for services.

Machine ssh keys must be of type `ed25519` so ensure your ssh servers have them.

```sh
just machine_age_pubkey {{server}}
```

6. **Build your .sops.yaml**

Build your `.sops.yaml` file based on the permissions of your hosts, check 
the `.sops.yaml` of this repo as an example.

With the retrieved public keys of `users` and `servers` you can define the permission scheme to access to your secrets.
public keys are set  in `keys:` section within the `.sops.yaml`


7. **Define your secrets**

Before defining your secrets ensure this machine have the user key installed!

```sh
sops secrets/example.yaml
```

** Updating secrets**
Imagine a key was leaked, or you just want to remove access to someone, you need to rotate data keys.

```sh
just update_secrets_keys
```
