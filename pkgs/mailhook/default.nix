{pkgs,...}:
pkgs.writeShellApplication { 
  name = "mail";
  runtimeInputs = [pkgs.busybox];
  text=''
    # Program name.
    prog_name="''${0##*/}"

    # Defaults.
    opt_message=""
    opt_subject="''${prog_name} alert"
    opt_file="/var/log/''${prog_name}.log"

    # Usage.
    usage() {
    cat <<EOF
    Usage: ''${prog_name} [-s subject] ...
    -s    Specify subject on command line (only the first argument after the -s flag is used as a subject; be careful to quote subjects containing spaces).
    -f    Change the location of the ''${prog_name} log file (default location is <''${opt_file}>).
    -h    Print this usage message.
    EOF
    }

    # Options.
    while getopts ':hs:f:' arg
    do
    case "''${arg}" in
        s)
        opt_subject="''${OPTARG}"
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

    # Log to file.
    touch "''${opt_file}" && {
    cat << EOF >> "''${opt_file}"
    |-------------------------- $(date -u '+%Y-%m-%d %H:%M:%S') UTC --------------------------|
    Subject: ''${opt_subject}

    ''${opt_message}
    |-----------------------------------------------------------------------------|
    EOF
    } || echo "Warning: log file <''${opt_file}> is not writeable."

    # Sanitizer.
    json() { printf '%s' "$1" | sed 's/\\/\\\\/g;s/\//\\\//g;s/\t/\\t/g;s/"/\\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g'; }

    # Arguments.
    json_header='Content-Type: application/json'
    json_data="$(
    printf '{"%s":"%s","%s":"%s"}' \
        'subject' "$(json "''${opt_subject}")" \
        'message' "$(json "''${opt_message}")"
    )"
    # Post.
    {
    curl -H "''${json_header}" -X POST -d "''${json_data}" --insecure "$@" 2>/dev/null
    } || {
    wget -O- --header="''${json_header}" --post-data="''${json_data}" --no-check-certificate "$@" 2>/dev/null
    } || {
    echo 'Error: Could not find curl or wget.' 1>&2
    exit 127
    }

    echo
    exit 0
    '';
    }