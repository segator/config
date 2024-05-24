{pkgs, ...}:
pkgs.python3Packages.buildPythonApplication  rec {
  pname = "nextcloud-config";
  version = "0.1.0";
  src = ./src;   
  
  propagatedBuildInputs = [
    pkgs.python3Packages.pyaml        
  ];
}