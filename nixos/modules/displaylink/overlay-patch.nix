final: prev: {
  linuxPackages_latest =
    prev.linuxPackages_latest.extend
      (lpfinal: lpprev: {
        evdi =
          lpprev.evdi.overrideAttrs (efinal: eprev: {
            version = "1.15.0-git";
            src = prev.fetchFromGitHub {
              owner = "DisplayLink";
              repo = "evdi";
              rev = "d21a6ea3c69ba180457966a04b6545d321cf46ca";
              sha256 = "sha256-Txa9yX9h3GfmHRRNvhrfrsUoQhqRWbBt4gJYAZTNe0w=";
            };
          });
      });
  displaylink = prev.displaylink.override {
    inherit (final.linuxPackages_latest) evdi;
  };
}