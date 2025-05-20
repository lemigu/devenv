#!/usr/bin/env bash

set -eo pipefail

setup_shell {
    if ! command -v brew >/dev/null 2>&1; then
        echo "could not find homebrew installation. going to install it"

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
        test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc

        echo "finished installing homebrew"
    fi

    brew_tools=( "cut" "jq" "awk" "fzf" "ripgrep" "bat" "yq" "lazygit" "tmux" "oh-my-posh" "nvim" )
    for tool in "${brew_tools[@]}"; do
        if ! command -v "${tool}" >/dev/null 2>&1; then
            echo "${tool} was not found, going to install via Homebrew..."

            case "${tool}" in
                "oh-my-posh")
                    brew install jandedobbeleer/oh-my-posh/oh-my-posh
                    ;;
                "cut")
                    brew install coreutils
                    ;;
                *)
                    brew install "${tool}"
            esac        
        fi
    done

    echo "updating .bashrc"
 
    cat <<'EOF' >> ~/.bashrc
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/theme.json)"
export PATH="$PATH:/home/linuxbrew/local/go/bin"
source ~/.config/aliases
EOF

}

setup_go {
    if ! command -v go >/dev/null 2>&1; then
        echo "could not find golang installation. going to install it"

        mkdir -p /home/linuxbrew/local
        wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
        tar -C /home/linuxbrew/local -xzf go1.24.3.linux-amd64.tar.gz
        rm go1.24.3.linux-amd64.tar.gz

        /home/linuxbrew/local/go/bin/go install golang.org/x/tools/gopls@latest
    fi
}

setup_shell

setup_go

