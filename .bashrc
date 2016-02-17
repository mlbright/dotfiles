# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022

[ "$(uname)" = "Darwin" ] && \
    [ -f "$HOME/.tmux-osx.conf" ] && \
    tmux source-file "$HOME/.tmux-osx.conf"

# https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#adding-your-ssh-key-to-the-ssh-agent
if [ -z "$SSH_AGENT_PID" ]; then
  eval "$(ssh-agent -s)"
fi

# bash completion
# brew install bash-completion
# shellcheck source=/dev/null
source "$(brew --prefix)/etc/bash_completion"
# shellcheck source=/dev/null
test -e "$HOME/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Use Neovim as "preferred editor"
export VISUAL=nvim
# Use Neovim instead of Vim or Vi
alias vim=nvim
alias vi=nvim
alias vimdiff="nvim -d"

export EDITOR=vim
set -o vi

export VIMCONFIG=~/.config/nvim
export VIMDATA=~/.local/share/nvim

# shellcheck source=/dev/null
if [ -f "$HOME/.employer" ]; then
  source "$HOME/.employer"
fi

# Possibly the most basic note taker in the world
# https://rehn.me/posts/using-vim-as-a-note-taking-app.html
if [ ! -d "$HOME/.notes" ]; then
  mkdir -p "$HOME/.notes"
fi
alias note="vim -c 'r!date' -c 'normal i# ' -c 'normal o' ~/.notes/notes.md"

# perl setup
# Read https://docs.brew.sh/Gems,-Eggs-and-Perl-Modules
# sudo chmod +a 'user:brightm allow add_subdirectory,add_file,delete_child,directory_inherit' /Library/Perl
# sudo cpan App::cpanminus

while read -r path
do
    if [[ -d "$path" && $(echo "$PATH" | grep -c "$path") -eq 0 ]]
    then
        PATH="$path:$PATH"
    fi
done << EOP
/usr/local/sbin
$HOME/.cargo/bin
$HOME/bin
$HOME/Local
EOP

PATH=$(perl -E 'chomp($_ = <>); say join":", grep { $_ && !$_{$_}++ } split/:/' <<< "$PATH")
export PATH

