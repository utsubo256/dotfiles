#!/usr/bin/env bash
set -x

REPO_DIR="$(cd "$(dirname "$0")" || exit 1; pwd)"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME/bin"

ln -sfv "$REPO_DIR/config/"* "$XDG_CONFIG_HOME/"
ln -sfv "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"
ln -sfv "$REPO_DIR/local/share/bin/"* "$XDG_DATA_HOME/bin/"
