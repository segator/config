{ pkgs, ...}:{    
    default =  pkgs.mkShell {
        buildInputs = with pkgs; [
            yq git just age ssh-to-age sops moreutils fzf nixos-rebuild
            (pkgs.python3.withPackages (python-pkgs: [
              python-pkgs.ruamel-yaml
            ]))
        ];

        shellHook = ''
            export SOPS_AGE_KEY_FILE=~/.secrets/nix/age_user_key.txt
        '';
    };
}