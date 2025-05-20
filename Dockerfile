FROM ubuntu:25.10

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl git build-essential sudo wget

RUN apt-get install -y coreutils jq gawk fzf ripgrep bat yq lazygit tmux 

RUN apt-get install -y python3 python3-dev python3-pip

# yes, I am using `--break-system-packages` for this one
RUN python3 -m pip install 'python-language-server[all]' --break-system-packages

# TODO : oh-my-posh

RUN useradd -m -s /bin/bash developer && \
	echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER developer

WORKDIR /home/developer/

RUN git clone --depth 1 --branch v0.11.1 https://github.com/neovim/neovim.git && \
    cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/home/developer/local && \
    cd .. && rm -rf neovim

RUN mkdir -p /home/developer/local && \
        wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz && \
        tar -C /home/developer/local -xzf go1.24.3.linux-amd64.tar.gz && \
        rm go1.24.3.linux-amd64.tar.gz && \
        /home/developer/local/go/bin/go install golang.org/x/tools/gopls@latest

RUN cat <<'EOF' >> /home/developer/.bashrc
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/theme.json)"
export PATH="$PATH:/home/developer/local/go/bin"
source ~/.config/aliases
EOF

COPY ./config/ /home/developer/.config

WORKDIR /home/developer/workspace

CMD [ "bash" ]

