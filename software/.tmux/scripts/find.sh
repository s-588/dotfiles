#!/usr/bin/env bash

# Start in the current directory tmux window was opened in
# $1 will be the starting directory passed from tmux

cd "$1" || exit 1

# Launch fzf to select a file
selected=$(fzf)

if [[ -n "$selected" ]]; then
  abs_path=$(realpath "$selected")
  cd "$(dirname "$abs_path")" || exit 1
  exec nvim "$abs_path"
else
  exec $SHELL
fi
