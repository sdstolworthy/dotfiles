#!/bin/bash

mkdir -p $HOME/.config/nvim/lua
mkdir -p $HOME/.config/alacritty
ln -s `pwd`/lua/*.lua $HOME/.config/nvim/lua/
ln -s `pwd`/alacritty.toml $HOME/.config/alacritty/alacritty.toml

ln -s `pwd`/tmux.conf $HOME/.tmux.conf
ln -s `pwd`/coc.nvim $HOME/.config/nvim/coc.nvim
ln -s `pwd`/coc-settings.json $HOME/.config/nvim/coc-settings.json
ln -s `pwd`/vimrc $HOME/.config/nvim/init.vim
ln -s `pwd`/profile $HOME/.profile
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
mkdir -p $ZSH_CUSTOM/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

