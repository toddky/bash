
# ==============================================================================
# INTERACTIVE?
# ==============================================================================
# Return if not interactive
case $- in
	*i*) ;;
	*) return;;
esac


# ==============================================================================
# SETTINGS
# ==============================================================================
stty erase ^?

# Use physical path
set -P

HISTCONTROL=ignoreboth
mkdir -p "$HOME/.bash_histories"
HISTFILE="$HOME/.bash_histories/$(date +%Y%m%d-%H%M%S).$(hostname -s).txt"
# Used as a format string for strftime(3) to print the time stamp associated with each entry.
HISTTIMEFORMAT='%F %T '
HISTSIZE=999999
HISTFILESIZE=999999


# ==============================================================================
# FISH
# ==============================================================================
#WHICH_FISH="$(which fish)"
#if [[ "$-" =~ i && -x "${WHICH_FISH}" && "${SHELL}" != "${WHICH_FISH}" ]]; then
#	# fish 3.1b1 (2020-01-26) or newer
#	if (fish --print-debug-categories &>/dev/null); then
#		exec env SHELL="${WHICH_FISH}" "${WHICH_FISH}" -i
#	else
#		exec env SHELL="${WHICH_FISH}" "${WHICH_FISH}" -i --debug-level 0
#	fi
#fi


# ==============================================================================
# ENVIRONMENT
# ==============================================================================
# Prepend directory to $PATH if the directory exists and isn't already included
function prepend_path() {
	local newpath="$1"
	[[ -d "$newpath" ]] || return 1
	[[ ":${PATH:=$newpath}:" =~ /.*:"$newpath":.*/ ]] && return
	PATH="$newpath:$PATH"
}

prepend_path "$HOME/.rbenv/bin"
if command -v rbenv &>/dev/null; then
	eval "$(rbenv init -)"
fi
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/bin"

if [[ -f "$HOME/.config/bash-local/bashrc" ]]; then
	source "$HOME/.config/bash-local/bashrc"
fi

CDPATH=".:$HOME/.config/links"
export EDITOR=vim

# LS_COLORS
if [[ -f "$HOME/.config/LS_COLORS" ]]; then
	eval $(dircolors -b "$HOME/.config/LS_COLORS")
fi


# ==============================================================================
# ALIASES
# ==============================================================================
alias bashrc='source ~/.bashrc'
function cdcat { cd "$(cat "$1")"; }
alias cdgit='cd "$(git rev-parse --show-toplevel)"'
alias cdl='cd $(stat -c "%Y %n" */ | sort -n | sed -n '"'"'$s/^[^ ]* //p'"'"')'
alias cdpwd='cd $(pwd)'
alias cdtemp='cd "$(mktemp -d)"'
alias cdram='cd "$(mktemp -d -p /dev/shm)"'
alias fish='fish --debug-level 0'
alias grep='grep -d skip -I --color=auto'
alias ll='LC_ALL=C ls -F -lrth --color=auto --group-directories-first'
alias la='ll -a'
alias pwd='pwd -P'
alias which='type'
alias unfunction='unset -f'

if command -v nvim &>/dev/null; then
	export EDITOR=nvim
	alias vi='nvim'
fi


# ==============================================================================
# FUNCTIONS
# ==============================================================================
# cd into anywhere/anything
function cd() {
	if [[ -z "$1" ]]; then
		builtin cd
	elif [[ "$1" == '-' ]]; then
		builtin cd - &>/dev/null
	elif [[ -d "$1" ]]; then
		builtin cd -P "$1" &>/dev/null
	elif [[ -f "$1" ]]; then
		builtin cd -P "$(dirname "$1")"
	elif (command which "$1" &>/dev/null); then
		builtin cd -P "$(dirname "$(command which $1)")"
	else
		builtin cd -P "$@" || return $?
	fi
	# TODO: Remove duplicates
	# https://unix.stackexchange.com/questions/288492/removing-duplicates-from-pushd-popd-paths
	pushd -n "$(builtin pwd -P)" &>/dev/null
	builtin pwd -P
}

# cdn function to cd using nnn
[[ -f "$HOME/bin/sourceme/cdn.bash" ]] && source "$HOME/bin/sourceme/cdn.bash"

# Use fzf to cd
function cdf() {
	local result dir
	result="$(fzfd)" || return $?
	dir="$(echo "$result" 2>/dev/null | sed "s|\$GIT_TOP|$(git-top)|")"
	print-cmd cd "$result"
	cd "$dir"
}

function cup() {
	local result
	result="$(path-tui)" || return
	cd "$result"
}


# ==============================================================================
# KEY BINDINGS
# ==============================================================================
# List keys
function bkeys() {
	if [[ -n "$@" ]]; then
		bind -P | grep "$@"
	else
		bind -P
	fi
}

# Set vi readline
bind -f "$HOME/.config/bash/inputrc"


# ==============================================================================
# PROMPT
# ==============================================================================
if command -v bash-prompt &>/dev/null; then

	# Set default prompt command
	PROMPT_COMMAND='PS1="$(bash-prompt)"'

	# Copy to /tmp for increased performance
	bash_prompt="/tmp/$USER-bash-prompt"
	(
		new_bash_prompt="$(command -v bash-prompt)"
		cmp --silent "$bash_prompt" "$new_bash_prompt" && return
		umask 022
		cp "$(command -v bash-prompt)" "$bash_prompt"
	)
	if chmod 755 "$bash_prompt"; then
		PROMPT_COMMAND='PS1="$("$bash_prompt")"'
	fi

	export start_ms
	function preexec() {
		RETVAL=$?
		[[ -n "$COMP_LINE" ]] && return
		if [[ "$BASH_COMMAND" == "$PROMPT_COMMAND" ]]; then
			((start_ms)) || return
			((RETVAL)) && echo -e "\e[31m(exited $RETVAL)\e[0m"
			return
		fi
		printf "\x1b[38;5;8m[$(date +%T)] Started\e[0m\n"
		start_ms="$(date +'%s%3N')"
	}
	trap 'preexec' DEBUG
fi

# command > preexec
# prompt_cmd > preexec
# draw drompt
# command
# redraw > preexec

# TODO: Figure out a better way to set this
#export TERM=alacritty


# ==============================================================================
# GOLANG
# ==============================================================================
# cd "$HOME"
# curl -L -O https://go.dev/dl/go1.23.5.linux-amd64.tar.gz
# tar -xzf go1.23.5.linux-amd64.tar.gz
export GOROOT="$HOME/go"
export GOPATH="$GOROOT/workspace"
export GOBIN="$GOROOT/bin"
export PATH="$PATH:$GOBIN"


# ==============================================================================
# TEMPORARY
# ==============================================================================
# Dot key is broken
alias cup='cd ..'
alias cup2='cd ../..'
alias cup3='cd ../../..'
alias cup4='cd ../../../..'
function cddot() {
	cd ".$1"
}

