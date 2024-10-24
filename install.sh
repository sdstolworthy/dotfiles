#!/bin/bash

mkdir -p $HOME/.config/nvim
mkdir -p $HOME/.config/alacritty
ln -s `pwd`/lua $HOME/.config/nvim/lua
ln -s `pwd`/alacritty.toml $HOME/.config/alacritty/alacritty.toml
ln -s `pwd`/tmux.conf $HOME/.tmux.conf
ln -s `pwd`/init.lua $HOME/.config/nvim/init.lua
ln -s `pwd`/profile $HOME/.profile
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
mkdir -p $ZSH_CUSTOM/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

