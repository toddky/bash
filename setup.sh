#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"

now=$(date +%Y%m%d-%H%M%S)

function symlink() {
	local src="$1"
	local dest="$2"
	if [[ "$(readlink -f "$dest")" == "$src" ]]; then
		return
	fi
	if [[ -e "$dest" && ! -L "$dest" ]]; then
		cp "$dest" "${dest}.backup.${now}"
	fi
	ln -sf "$src" "$dest"
}

symlink "$CURRENT_DIR/bashrc"  "$HOME/.bashrc"
symlink "$CURRENT_DIR/inputrc" "$HOME/.inputrc"
