{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  boot = {
      kernelPackages = pkgs.linuxPackages_6_1.extend (_: prev: {
        zfs_unstable = prev.zfs_unstable.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "openzfs";
            repo = "zfs";
            rev = "pull/14531/head";
            sha256 = "sha256-TaptNheaiba1FBXGW2piyZjTIiScpaWuNUGvi5SglPE=";
          };
        });

      });
      zfs = {
        package = pkgs.zfs_unstable;
      };
      supportedFilesystems = ["zfs"];

  };
}