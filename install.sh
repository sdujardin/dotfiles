#!/usr/bin/env bash

set -e -o pipefail -o nounset

# Warn that some commands will not be run if the script is not run as root.
if [[ $EUID -ne 0 ]]; then
  RUN_AS_ROOT=false
  printf "Certain commands will not be run without sudo privileges. To run as root, run the same command prepended with 'sudo', for example: $ sudo $0\n\n" | fold -s -w 80
else
  RUN_AS_ROOT=true
  # Update existing `sudo` timestamp until `.osx` has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

readonly dotfiles_dir="$HOME/.dotfiles"

if [ "$(uname)" = "Darwin" ]; then
    LN='ln -sf'
    mkdir -p "$HOME"/{.vim,.tmux/plugins}
else
    LN='ln -srf'
    mkdir -p "$HOME"/{.vim,.tmux/plugins}
fi

if ! which lua > /dev/null
then
	curl -s -o /tmp/lua.tar.gz http://www.lua.org/ftp/lua-5.3.5.tar.gz
	cd /tmp/ && tar zxf lua-5.3.5.tar.gz && rm lua.tar.gz && cd lua-5.3.5
	make macosx test
	mv src/lua /usr/local/bin && mv srv/luac /usr/local/bin
fi

mkdir -p "$HOME"/{.config/htop,.modules}

${LN} "$dotfiles_dir/shell/bashrc" "$HOME/.bashrc"
${LN} "$dotfiles_dir/shell/inputrc" "$HOME/.inputrc"

# shellcheck disable=2086
${LN} "$dotfiles_dir/modules/bash-it" "$HOME/.bash_it"
${LN} "$dotfiles_dir/apps/tmux.conf" "$HOME/.tmux.conf"
${LN} "$dotfiles_dir/apps/vimrc" "$HOME/.vimrc"
${LN} "$dotfiles_dir/apps/gitconfig" "$HOME/.gitconfig"
${LN} "$dotfiles_dir/apps/htoprc" "$HOME/.config/htop/htoprc"
${LN} "$dotfiles_dir/apps/toprc" "$HOME/.toprc"
${LN} "$dotfiles_dir/apps/dir_colors" "$HOME/.dir_colors"

${LN} "$dotfiles_dir/modules/tpm" "$HOME/.tmux/plugins/"

git clone git@github.com:skywind3000/z.lua.git "$dotfiles_dir/modules/z.lua"

. "$HOME/.bashrc"

bash-it enable plugin git
bash-it enable alias git