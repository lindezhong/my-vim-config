#!/bin/bash

home_path=$(readlink -f $(dirname "$0"))
# 配置ubuntu终端颜色方案
bash dconf/load_dconf.sh terminal "/org/gnome/terminal/legacy/" "$home_path/dconf/one-half-dark-terminal.dconf"

rm ~/.vimrc
ln -s ${home_path}/vimrc ~/.vimrc

sudo apt install -y nodejs npm
sudo npm install -g n
sudo n stable
sudo apt install -y python3-pip
sudo apt install -y python3-venv

# 下载vim插件
for (( i=0; i<10; i++ ));
do
bash ./vim.git
done

