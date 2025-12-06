if status is-interactive
    # Commands to run in interactive sessions can go here
end

function config
	git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end

set -U fish_greeting

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
