#!/usr/bin/env bash

set -eo pipefail

if ! command -v brew >/dev/null 2>&1; then
	echo "could not find homebrew installation. going to install it"

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
	test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc

	echo "finished installing homebrew"
fi

brew_tools=( "cut" "jq" "awk" "fzf" "ripgrep" "bat" "yq" "gitui" "tmux" "oh-my-posh" "micro" )
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

cat <<EOF >> ~/.bashrc

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/theme.json)"

[ -z "$TMUX"  ] && { tmux attach || exec tmux new-session && exit;}

source ~/.config/aliases

EOF

mkdir -p ~/.config
