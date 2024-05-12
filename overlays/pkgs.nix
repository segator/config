(final: prev: 
          builtins.mapAttrs (path: _: final.callPackage (../pkgs + "/${path}") {} )
          (builtins.readDir ../pkgs)
        
)