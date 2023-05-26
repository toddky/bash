#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"

bashrc="$CURRENT_DIR/bashrc"
inputrc="$CURRENT_DIR/inputrc"

ln -sfn "$bashrc" "$HOME/.bashrc"
ln -sfn "$inputrc" "$HOME/.inputrc"

