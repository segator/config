let
    newPackages = final: builtins.mapAttrs (path: _: final.callPackage (../pkgs + "/${path}") {} )
        (builtins.readDir ../pkgs);
in
(final: prev: 
    newPackages final //
    {

    }        
)