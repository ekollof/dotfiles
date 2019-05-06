#
# User configuration sourced by interactive shells
#

if [ ! -d ~/.zim ]; then
    git clone --recursive https://github.com/zimfw/zimfw.git ${ZDOTDIR:-${HOME}}/.zim

    for template_file in ${ZDOTDIR:-${HOME}}/.zim/templates/*; do
        user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"
        cat ${template_file} ${user_file}(.N) > ${user_file}.tmp && mv ${user_file}{.tmp,}
    done
fi


# Define zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='nvim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias mutt=neomutt
alias vim=nvim

# misc functions
function reload_gtk() {
  theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
  gsettings set org.gnome.desktop.interface gtk-theme ''
  sleep 1
  gsettings set org.gnome.desktop.interface gtk-theme $theme
}

# Do these steps first:
#
# git init --bare $HOME/.cfg
# alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
# config config --local status.showUntrackedFiles no
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# KVM
export VIRSH_DEFAULT_CONNECT_URI=qemu:///system
export LIBVIRT_DEFAULT_URI=qemu:///system

# added by pipsi (https://github.com/mitsuhiko/pipsi)
export PATH="$HOME/.local/bin:$PATH"

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Gem
PATH="$PATH:$(ruby -e 'puts Gem.user_dir')/bin"

# xterm transparency
if [ -v XTERM_VERSION ]
then
    transset-df --id "$WINDOWID" 0.85 > /dev/null
fi

#if [ $TERM != "st" ]; then
#    wal -n -R -q
#fi

neofetch | lolcat

