#!/usr/bin/env bash

set -euo pipefail

DEV_IMAGE="ghcr.io/lemigu/devtools:latest"
CONTAINER_USER="developer"
CONTAINER_ENGINE="docker"

usage () {
    echo "Usage: $0 <subcommand> [args]"
    echo "Subcommands:"
    echo "  create  <name> [-p <path to mount>]     Create a new devenv"
    echo "  list                                    Display existing devenvs"
    echo "  connect <name>                          Activate and connect to devenv"
    echo "  archive <name>                          Stop and archive devenv"
    echo "  destroy <name>                          Destroy devenv"
    echo "  help                                    Show this menu"
}

check_args() {
    if [[ $# -lt 1 ]] ; then
        echo "Expected at least 1 argument, got $#"
        usage
        exit 1
    fi
}

create () {
    check_args $@

    local container_name="$1"
    shift

    if [[ $container_name = *" "* ]]; then
        echo "devenv name cannot contain whitespace: '$container_name'"
        exit 1
    fi

    local to_mount=""
    while getopts "p:" opt; do
        case "$opt" in
            p)
                to_mount="$OPTARG"
                if [[ ! -d "$to_mount" ]]; then
                    echo "Specified path $to_mount is not a valid directory"
                    return 1
                fi
                ;;
            *)
                echo "Unexpected option $opt"
                usage
                exit 1
        esac
    done

    local mount_cmd=""
    if [[ -n "$to_mount" ]]; then
        mount_cmd="-v $to_mount:/home/$CONTAINER_USER/workspace"
    fi
    
    $CONTAINER_ENGINE run -it --name devenv-$container_name \
        --platform linux/amd64 \
        $mount_cmd \
        -v ~/.ssh:/home/$CONTAINER_USER/.ssh:ro \
        -v ~/.gitconfig:/home/$CONTAINER_USER/.gitconfig:ro \
        $DEV_IMAGE
}

list () {
    local devenvs=$($CONTAINER_ENGINE ps -a --filter "name=^/devenv-" --format "{{.Names}}---{{.Status}}")
    if [[ -z "$devenvs" ]]; then
        echo "No devenvs found"
        exit 0
    fi

    {
        echo -e "DEVENV\tSTATUS"
        while IFS= read -r devenv; do
            container_name="${devenv%%---*}"
            devenv_name="${container_name#devenv-}"
            
            container_status="${devenv##*---}"
            devenv_status="inactive"

            if [[ $container_status == Up* ]]; then
                devenv_status="active"
            fi
           
            echo -e "$devenv_name\t$devenv_status"
        done <<< "$devenvs"
    } | column -t -s $'\t'
}

connect () {
    check_args $@

    $CONTAINER_ENGINE start devenv-$1
    $CONTAINER_ENGINE exec -it devenv-$1 bash
}

archive () {
    check_args $@

    $CONTAINER_ENGINE stop devenv-$1
}

destroy () {
    check_args $@

    $CONTAINER_ENGINE rm -f devenv-$1
}

if ! command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE="podman"
    
    if ! command -v podman >/dev/null 2>&1; then
        echo "either docker or podman is required to use $0"
        exit 1
    fi
fi

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

case "${1:-}" in
    create)
        shift
        create "$@"
        ;;
    list)
        shift
        list
        ;;
    connect)
        shift
        connect "$@"
        ;;
    archive)
        shift
        archive "$@"
        ;;
    destroy)
        shift
        destroy "$@"
        ;;
    help)
        usage
        ;;
    *)
        echo "Unknown subcommand: $1"
        usage
        ;;
esac

