# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.

# make sure we are in the interactive mode
[[ $- != *i* ]] && return

# load custom bash aliases
[ -s ~/.aliases ] && source ~/.aliases

# history: ignore duplicates and skip whitespace
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT='%F %r  '
export HISTFILESIZE=100000
export HISTSIZE=-1
# do not store garbage/irrelevant commands
export HISTIGNORE="history:pwd:..:..."
export HISTIGNORE="$HISTIGNORE:ls:la:ll:l.:ll."

# colorize ls output
command -v dircolors > /dev/null && eval "$(dircolors -b)"

# display more with less
command -v lesspipe > /dev/null \
	&& export LESSOPEN="|lesspipe %s" LESSCLOSE="lesspipe %s %s"
export LESSCOLORIZER=/usr/bin/src-hilite-lesspipe.sh

# history: fuzzy reverse search
command -v fzy > /dev/null \
	&& bind -x '"\C-r": __history_fuzzy_search'
__history_fuzzy_search() {
	READLINE_LINE=$(
		HISTTIMEFORMAT=
		history | sort -rn \
			| awk '{ $1="" ; if (!x[$0]++) print substr($0,2) }' \
			| fzy -q "$READLINE_LINE")
	READLINE_POINT=0x7FFFFFFF
}

# setup adaptive prompt
if [ -f /usr/share/liquidprompt/liquidprompt ]; then
	source /usr/share/liquidprompt/liquidprompt
elif [ -f /usr/share/git/git-prompt.sh ]; then
	# git repository status tweaks
	export GIT_PS1_SHOWDIRTYSTATE=true
	export GIT_PS1_SHOWSTASHSTATE=true
	export GIT_PS1_SHOWUNTRACKEDFILES=true
	export GIT_PS1_SHOWCOLORHINTS=true
	# show git repository status in prompt
	PROMPT_CMD_PRE='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[00m\]'
	PROMPT_CMD_POST=' \[\033[01;34m\]\$\[\033[00m\] '
	PROMPT_COMMAND="__git_ps1 \"$PROMPT_CMD_PRE\" \"$PROMPT_CMD_POST\""
	source /usr/share/git/git-prompt.sh
fi

# required by curses-based pinentry
export GPG_TTY=$(tty)

# load our X-based pinentry GPG agent
if [ -n "${DISPLAY}" ] && [ -s ~/.gpg-agent-info ]; then
	. ~/.gpg-agent-info
fi

# start X on login
if [ -z "${DISPLAY}" ] && [ "$(tty)" = /dev/tty1 ]; then
	XSERVER="/usr/bin/X :0 -nolisten tcp vt7"
	exec xinit -- $XSERVER >& /tmp/.xsession-errors
fi
