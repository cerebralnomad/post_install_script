# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/wget 
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="clay"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
#DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
#DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins w3denould you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(colored-man-pages command-not-found)

# User configuration

export PATH="/home/clay/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/clay/.local/bin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh
# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# My terminal aliases

source $HOME/aliases

# Enable case insensitive autocomplete
#autoload -Uz compinit && compinit
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


EDITOR=nano
export EDITOR
export HISTSIZE=100000000

# auto runs the fortune program on terminal launch
# the fortunes are located at /usr/share/games/fortunes

#if [ -x /usr/games/fortune ]; then
#    fortune | cowsay
#fi

# Uncomment the following line to enable fortune with cowsay
# fortune | cowsay | lolcat

# If reminder file doesn't exist, create it

if [[ ! -f ~/Documents/reminder ]]; then
        touch ~/Documents/reminder
        echo "" > ~/Documents/reminder
        echo "To Do List" >> ~/Documents/reminder
        echo "==========" >> ~/Documents/reminder
fi

# If reminders exist, do not show fortune

if [[ $(wc -l < ~/Documents/reminder) -ge 4 ]]; then
    cat ~/Documents/reminder
elif [[ ! -d /usr/share/games/fortunes/off ]]; then
        fortune
else
    fortune -o -n 380
fi

# The below fortune code randomizes the character used be cowsay
# Some of the characters are quite large and can get annoying

# fortune | cowsay -f $(ls /usr/share/cowsay/cows/ | shuf -n1) | lolcat

source ~/.zsh_scripts/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

source ~/.config/broot/launcher/bash/br
