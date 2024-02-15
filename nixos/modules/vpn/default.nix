{ inputs, config, pkgs,  lib, ... }:
{
    sops.secrets."vpn" = {
        sopsFile = ../../../secrets/common/work-vpn.nmconnection;
        format = "binary";
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/etc/NetworkManager/system-connections/work.nmconnection";
    };

     environment.etc."NetworkManager/dispatcher.d/vpn.sh".source =
        pkgs.writeShellScript "vpn.sh" ''
            PROFILE_ID="tun0"
            INTERNAL_NETWORK="10.0.0.0/8"
            if [ "$CONNECTION_ID" != "$PROFILE_ID" ]; then
                exit 1
            fi

            case "$2" in
                up)
                    # VPN is connected, add the route
                    ${pkgs.busybox}/bin/ip route add $INTERNAL_NETWORK dev $1
                    ;;
                pre-down)
                    # VPN is disconnected, remove the route
                    ${pkgs.busybox}/bin/ip route del $INTERNAL_NETWORK dev $1
                    ;;
            esac
        '';
}

