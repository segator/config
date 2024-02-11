{ pkgs, ...}:
    with pkgs;
        mkShell {
        buildInputs = [
            git just age ssh-to-age sops moreutils
        ];

        shellHook = ''
            export SOPS_AGE_KEY_FILE=~/.secrets/nix/age_user_key.txt
        '';
}