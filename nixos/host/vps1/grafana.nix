
{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    grafanaFqdn = "grafana.segator.es";
in
{
  services = {
    grafana = {
      enable = true;
      provision.enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          domain = grafanaFqdn;
        };
        # auth = {
        #   disable_login_form = true;
        #   login_cookie_name = "_oauth2_proxy";
        #   oauth_auto_login = true;
        #   signout_redirect_url = "https://grafana.${hostName}.meurer.org/oauth2/sign_out?rd=https%3A%2F%2Fgrafana.${hostName}.meurer.org";
        # };
        # "auth.basic".enabled = false;
        # "auth.proxy" = {
        #   enabled = true;
        #   auto_sign_up = true;
        #   enable_login_token = false;
        #   header_name = "X-Email";
        #   header_property = "email";
        # };
        # users = {
        #   allow_signup = false;
        #   auto_assign_org = true;
        #   auto_assign_org_role = "Viewer";
        # };
      };
    };

    nginx = {
      virtualHosts = {
        "${grafanaFqdn}" = {
          forceSSL = true;
          enableACME = true;
          kTLS = true;
          location."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
            proxyWebsockets = true;
          };
          # From [1] this should fix downloading of big files. [2] seems to indicate that buffering
          # happens at multiple places anyway, so disabling one place should be okay.
          extraConfig = ''
            proxy_buffering off;
          '';
        };


      };
    };   
  };
}