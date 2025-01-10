# shellcheck disable=SC2148
export HISTSIZE=1000000
export HISTSAVE=1000000
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# Create a local directory for your programs
mkdir -p "$HOME/.local/bin"
PATH="$HOME/.local/bin:$PATH"

# Path to your oh-my-zsh installation.
ZSH="$HOME/.oh-my-zsh"
export ZSH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# shellcheck disable=SC2034
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=30

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"
# shellcheck disable=SC2034
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# shellcheck disable=SC2034
plugins=(git zsh-vi-mode macos zsh-syntax-highlighting zsh-autosuggestions zoxide)

# shellcheck disable=SC1091
source "$ZSH/oh-my-zsh.sh"

# User configuration

if [[ "$OSTYPE" == "darwin"* ]]; then
  export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
fi

# Do not page AWS CLI results
export AWS_PAGER=

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
[ -d "$HOME/.local/nvim" ] && export EDITOR='nvim'

# Uncomment to use GNU versions
# if [[ "$OSTYPE" == "darwin"* && -d "/usr/local/opt/coreutils/libexec/gnubin" ]]; then
#   PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
# fi

[[ -f "$HOME/.atuin/bin/atuin" ]] && export PATH="$HOME/.atuin/bin:$PATH"

# shellcheck disable=SC1091
[ -d "$HOME/.local/go" ] && [ -d "$HOME/.local/go" ] && GOPATH="$HOME/.local/go" && export PATH="$GOPATH/bin:$PATH"

# neovim
[ -d "$HOME/.local/nvim" ] && PATH="$HOME/.local/nvim/bin:$PATH" && export PATH

# export PATH="/usr/local/opt/llvm/bin:$PATH"

[ -d "$HOME/.local/poetry/bin" ] && export PATH="$HOME/.local/poetry/bin:$PATH"

PATH="$(echo -n "$PATH" | awk -v RS=: '!($0 in a) {a[$0]; printf("%s%s", length(a) > 1 ? ":" : "", $0)}')"
export PATH

VI_MODE_SET_CURSOR=true

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias printable='perl -p -e "s/.*[^[:print:]]+//"'
alias dotfiles='ls -ld ~/.??*'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec ${SHELL} -l'

alias myip='curl -s http://ipecho.net/plain'
alias weather='curl https://wttr.in/Toronto\?m'
alias memusage='ps -o rss,command -waxc | sort -n'
alias headerdump='curl -D- -o/dev/null'

if [[ -n "$(where nvim)" ]]; then
  alias vim='nvim'
fi

# https://starship.rs/guide/
if [[ -f "$(where starship)" ]]; then
  eval "$(starship init zsh)"
fi

if [[ -f "$(where atuin)" ]]; then
  eval "$(atuin init zsh)"
fi

[[ -f ~/.local/bin/mise ]] && eval "$(~/.local/bin/mise activate zsh)"

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
