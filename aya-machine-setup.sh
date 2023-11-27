#!/bin/bash

# Set up a machine for Aya development

sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install -y build-essential
sudo apt install -y pkg-config
sudo apt install -y libssl-dev
sudo apt install -y luajit
sudo apt install -y unzip # for successful stylua installation inside neovim?
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup install stable
rustup toolchain install nightly --component rust-src
cargo install bpf-linker
cargo install cargo-generate
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

curl -L -O https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar zxvf nvim-linux64.tar.gz 
mv nvim-linux64 ~/.local
curl -O https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}

sudo apt install -y fontconfig
sudo apt install -y termshark
