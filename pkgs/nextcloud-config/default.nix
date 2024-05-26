{pkgs, occCommand ? "nextcloud-occ", ...}:
pkgs.python3Packages.buildPythonApplication  rec {
  pname = "nextcloud-config";
  version = "0.1.0";
  src = ./src;   

  shellHook = ''
    export OCC_COMMAND="nextcloud-occ"
  '';
  OCC_COMMAND = occCommand;
  
  propagatedBuildInputs = [
    pkgs.python3Packages.pyaml        
  ];
}