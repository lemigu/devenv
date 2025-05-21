# devenv

**TLDR:** [VS Code DevContainers](https://learn.microsoft.com/en-us/training/modules/use-docker-container-dev-env-vs-code/) but without VS Code.

This repo builds an opinionated devcontainer and also has a CLI tool for managing running `devenvs`.

Using the tool to create a devenv will automatically mount git and ssh configurations and credentials onto the container as read-only.

Requires either `docker` or `podman` to be installed on the host.

