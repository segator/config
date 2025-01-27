{ config, pkgs, ... }:
let
    hipReportPath = ".config/.roche/vpn/hipreport.sh";
    serverCertPin = "pin-sha256:K05dEPblSWXoIvlUO9KtoA3bBhWzEy2O9LF1wbVxXig=";
in
{
  sops.secrets.roche_pass = {};
  sops.secrets.vpn_gp_gateway = {};
  sops.secrets.vpn_gp_authgroup = {};
  home.file."${hipReportPath}" = {
    executable = true;
    source = ./hipreport.sh;
  };


  # Create the roche-vpn script
  home.file.".local/bin/roche-vpn" = {
    executable = true;
    text = ''


    LOG_FILE="/var/log/gpclient.log"

    case "$1" in
      start)
        # Check if VPN is already running
        if [ -e /var/run/gpclient.lock ]; then
          PID=$(cat /var/run/gpclient.lock)
          if ps -p "$PID" >/dev/null 2>&1; then
            echo "VPN is already running (PID $PID)."
            exit 1
          else
            sudo rm /var/run/gpclient.lock
          fi
        fi

        # Start VPN in background
        echo "Starting Roche VPN..."
        cat ${config.sops.secrets.roche_pass.path} | sudo ${pkgs.gpclient}/bin/gpclient connect \
            --as-gateway \
            --disable-ipv6 \
            --user=${config.home.username} \
            --passwd-on-stdin \
            --script /usr/share/vpnc-scripts/vpnc-script \
            --hip \
            --sslkey "${config.home.homeDirectory}/.config/rlcaas-roche/${config.home.username}.key" \
            --certificate "${config.home.homeDirectory}/.config/rlcaas-roche/${config.home.username}.pem" \
            $(cat ${config.sops.secrets.vpn_gp_gateway.path}) > $LOG_FILE 2>&1 &

        # Disown process so it survives terminal exit
        disown
        echo "VPN started in background"
        ;;

      stop)
        echo "Stopping Roche VPN..."
        sudo ${pkgs.gpclient}/bin/gpclient disconnect
        ;;

      status)
        if [ -e /var/run/gpclient.lock ]; then
          PID=$(cat /var/run/gpclient.lock)
          if ps -p "$PID" >/dev/null 2>&1; then
            echo "✅ VPN is running (PID $PID)"
          else
            echo "⚠️  PID file exists but process not found (PID $PID)"
          fi
        else
          echo "❌ VPN is not running"
        fi
        ;;

      *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
    esac

    exit 0
    '';
  };

}