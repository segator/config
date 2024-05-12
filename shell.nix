{ pkgs, ...}:
let
 repl = pkgs.writeShellScriptBin "repl" ''
            host=$(${pkgs.busybox}/bin/hostname);
            if [ ! -z "$1" ]; then
              host="$1";
            fi
            ${pkgs.nix}/bin/nix --extra-experimental-features repl-flake repl ".#nixosConfigurations.$host"
        '';
  py3_packages = pkgs.python3.withPackages (python-pkgs: [
              python-pkgs.ruamel-yaml
            ]);
in 
{    
    default = pkgs.mkShell {
        buildInputs = with pkgs; [
            yq
            git
            just
            age
            ssh-to-age
            sops
            moreutils
            fzf
            nixos-rebuild 
            nix-tree
            py3_packages
            repl
        ];

        shellHook = ''
            export SOPS_AGE_KEY_FILE=~/.secrets/nix/age_user_key.txt
            echo "Type 'help' for shell usage instructions."
        '';
    };
}