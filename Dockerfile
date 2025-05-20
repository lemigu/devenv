FROM ubuntu:25.10

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl git build-essential sudo wget cmake unzip locales

RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

RUN apt-get install -y coreutils jq gawk fzf ripgrep bat yq lazygit tmux tree neovim 

RUN apt-get install -y python3 python3-dev python3-pip

# yes, I am using `--break-system-packages` for this one
RUN python3 -m pip install 'python-language-server[all]' --break-system-packages

RUN useradd -m -s /bin/bash developer && \
	echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip && \
    unzip /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts/JetBrainsMono && \
    fc-cache -fv && \
    rm /tmp/JetBrainsMono.zip

USER developer

WORKDIR /home/developer/

RUN mkdir -p /home/developer/local && \
        wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz && \
        tar -C /home/developer/local -xzf go1.24.3.linux-amd64.tar.gz && \
        rm go1.24.3.linux-amd64.tar.gz && \
        /home/developer/local/go/bin/go install golang.org/x/tools/gopls@latest

RUN mkdir -p /home/developer/.local/bin && curl -s https://ohmyposh.dev/install.sh | bash -s

RUN cat <<'EOF' >> /home/developer/.bashrc
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/theme.json)"
export PATH="$PATH:/home/developer/local/go/bin:/home/developer/local/bin:/home/developer/local:/home/developer/go/bin:/home/developer/.local/bin:/usr/local/bin"
[ -z "$TMUX"  ] && { tmux attach || exec tmux new-session && exit;}
EOF

COPY ./dotfiles/nvim/ /home/developer/.config/nvim

COPY ./dotfiles/tmux/ /home/developer/.config/tmux

COPY ./oh-my-posh/ /home/developer/.config/oh-my-posh

RUN sudo chown -R developer:developer /home/developer/.config

RUN nvim --headless "+Lazy! sync" +qa

RUN echo "// bootstrap.go" > /tmp/bootstrap.go && \
    nvim --headless /tmp/bootstrap.go \
    "+lua require('lazy').sync()" \
    "+sleep 60" \
    +qa

RUN rm -rf /tmp/bootstrap.go

WORKDIR /home/developer/workspace

CMD [ "bash" ]

