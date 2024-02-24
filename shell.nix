{ pkgs, ...}:{    
    default =  pkgs.mkShell {
        buildInputs = with pkgs; [
            git just age ssh-to-age sops moreutils
        ];

        shellHook = ''
            export SOPS_AGE_KEY_FILE=~/.secrets/nix/age_user_key.txt
        '';
    };
}