#!/usr/bin/env bash
sudo yum groups install -y Development\ tools
sudo yum install -y cmake3
sudo yum install -y python3-{devel,pip}
sudo pip-3 install neovim --upgrade
(
cd "$(mktemp -d)"
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install
)
