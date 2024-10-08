{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Isaac Aymerich";
    userEmail = "isaac.aymerich@roche.com";
    
    aliases = {
      pu = "push";
      co = "checkout";
      cm = "commit";
    };
    extraConfig = {
      pull.rebase = true;
      core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519";
      };
    };

    includes = [
      {
        contents = {
          user = {
            email = "isaac.aymerich@roche.com";
          };

          core = {
            sshCommand = "ssh -i ~/.ssh/id_rsa_roche";
          };
        };
        condition = "hasconfig:remote.*.url:git@github.com:Roche-DIA-RIS-*/**";
      }
      {
        contents = {
          user = {
            email = "isaac.aymerich@roche.com";
          };

          core = {
            sshCommand = "ssh -i ~/.ssh/id_rsa_roche";
          };
        };
        condition = "hasconfig:remote.*.url:git@ssh.code.roche.com:*/**";        
      }
    ];
  };
  
  home.packages = with pkgs; [
    lazygit
  ];
}
