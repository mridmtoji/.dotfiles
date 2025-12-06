if status is-interactive
    # Commands to run in interactive sessions can go here
end

function config
	git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end

set -U fish_greeting
