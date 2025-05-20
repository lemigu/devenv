# devtools

Tree

```
TODO @lemigu : snapshot of filetree, with comments on what each folder contains ??
```

---

TODO List:
- utility scripts / binaries / cli tools inside `tools` folder
- Dockerfiles inside `containers` folder, containing pre-packaged container for Go/Python development with my `tools` already preconfigured
- `setmeup.sh` script at the root for installing and configuring all `tools` and dependencies locally on the caller system
- pipelines for building and releasing the containers
- script for opening current directory inside a development container, mounting the directory in it, as well as mounting ssh keys and (ideally) inheriting gitconfig as well
- font setup? `TODO @lemigu : important !!`
- specific terminal emulator setup?
- ~/.config folder for relevant apps
- install `go` and `python3` and their respective LSPs, formatters, linters, typecheckers, etc.


- `devenv` CLI
  - `devenv create <name> [-p path_to_mount]<optional>` - creates a headless (?) Docker container devenv with the mounted directory
  - `devenv list` - shows active/inactive devenvs (aka containers)
  - `devenv connect <name>` - connects to a devenv (aka container)
  - `devenv start <name>` - starts and connects to the specified devenv (aka container)
  - `devenv stop <name>` - stops the specified devenv (aka container)
  - `devenv destroy <name>` - destroys the specified devenv (aka container)


Going to function definition:
```
go install golang.org/x/tools/gopls@latest

Just this might be enough: python3 -m pip install 'python-language-server[all]'

python3 -m pip install --user jedi
python3 -m pip install --user python-lsp-server

Note: For Python, ensure Location in output of `python3 -m pip show python-lsp-server` is in PATH 
```



TMUX:
- (start it on bashrc)
- `CTRL+b c` - create new window
- `CTRL+b <number>` - to swap between windows
- `CTRL+b %` - split side by side
- `CTRL+b "` - split top and bottom
- `CTRL+b o` - swapping between panes (can use arrow keys instead of `o` as well)
- `CTRL+b $` - rename session
- `CTRL+b ,` - rename pane
- `[ -z "$TMUX"  ] && { tmux attach || exec tmux new-session && exit;}` - on bashrc to always start tmux

