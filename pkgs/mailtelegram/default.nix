{pkgs,
 telegram_bot_token ? "/etc/mailtelegram/telegram_bot_token",
 telegram_chatid ? "/etc/mailtelegram/secrets/telegram_chatid",
 name ? "mailtelegram",
 ...}:
pkgs.writeShellApplication { 
  inherit name;
  runtimeInputs = [pkgs.busybox];
  text=''
    # Program name.
    prog_name="''${0##*/}"

    # Defaults.
    opt_message=""
    opt_subject="''${prog_name} alert"
    opt_hostname="''$(hostname)"
    if [ -f "${telegram_bot_token}" ]; then
        opt_telegram_bot_token=''$(cat ${telegram_bot_token})
    fi

    if [ -f "${telegram_chatid}" ]; then
        opt_telegram_chatid=''$(cat ${telegram_chatid})
    fi

    opt_file="/var/log/''${prog_name}.log"

    # Usage.
    usage() {
    cat <<EOF
    Usage: ''${prog_name} [-s subject] ...
    -s    Specify subject on command line (only the first argument after the -s flag is used as a subject; be careful to quote subjects containing spaces).
    -f    Change the location of the ''${prog_name} log file (default location is <''${opt_file}>).
    -t    Telegram Bot Token Path.
    -c    Telegram Chat Id Path.
    -h    Print this usage message.
    EOF
    }

    # Options.
    while getopts ':hs:t:c:f:' arg
    do
    case "''${arg}" in
        s)
        opt_subject="''${OPTARG}"
        ;;
        t)
        opt_telegram_bot_token=''$(cat "''${OPTARG}")
        ;;
        c)
        opt_telegram_chatid=''$(cat "''${OPTARG}")
        ;;
        f)
        opt_file="''${OPTARG}"
        ;;
        h | *)
        usage
        exit 0
        ;;
    esac
    done
    shift $((OPTIND - 1))

    #[ $# -eq 1 ] || usage && exit 2

    # Input.
    [ -t 0 ] && {
    echo 'Error: STDIN must be a pipe or file.' 1>&2
    exit 2
    } || opt_message="$(cat </dev/stdin)"



    # Arguments.
    data="*Host:* ''${opt_hostname} \r\n*Subject:* ''${opt_subject}\r\n\r\n\`\`\` ''${opt_message} \`\`\`"
    
    curl -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"''${opt_telegram_chatid}\", \"text\": \"''${data}\",\"parse_mode\": \"MarkdownV2\"}" \
        "https://api.telegram.org/bot''${opt_telegram_bot_token}/sendMessage"
    

    # Log to file.
    touch "''${opt_file}" && {
    cat << EOF >> "''${opt_file}"
    |-------------------------- $(date -u '+%Y-%m-%d %H:%M:%S') UTC --------------------------|
    Host: ''${opt_hostname}
    Subject: ''${opt_subject}

    ''${opt_message}
    |-----------------------------------------------------------------------------|
    EOF
    } || echo "Warning: log file <''${opt_file}> is not writeable."

    echo
    exit 0
    '';
    }