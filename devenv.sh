#!/usr/bin/env bash

set -euo pipefail

DEV_IMAGE="ghcr.io/lemigu/devtools:latest"
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

create () {
    if [[ $# -lt 1 ]] ; then
        echo "Expected at least 1 argument, got $#"
        usage
        exit 1
    fi

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
    
    $CONTAINER_ENGINE run -it --name devenv-$container_name \
        --platform linux/amd64 \
        -v $to_mount:/home/developer/workspace \
        -v ~/.ssh:/home/developer/.ssh:ro \
        -v ~/.gitconfig:/home/developer/.gitconfig:ro \
        $DEV_IMAGE
}

list () {
    local devenvs=$($CONTAINER_ENGINE ps -a --filter "name=^/devenv-" --format "{{.Names}}---{{.Status}}")
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
    echo "connect"
}

archive () {
    echo "archive"
}

destroy () {
    echo "destroy"
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

