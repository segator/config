{ config, pkgs, nixpkgs, lib, ... }:
{

  boot.kernelParams = [ "acpi_osi=!" "acpi_osi=!*" "acpi_osi=\"Windows 2015\""];
  boot.loader.grub = {
    extraFiles."dsdt.aml" = ./dsdt.aml;
    extraConfig = ''
    acpi /dsdt.aml
    '';
  };
}