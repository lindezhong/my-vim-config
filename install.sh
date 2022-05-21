#!/bin/bash

home_path=$(readlink -f $(dirname "$0"))
# 配置ubuntu终端颜色方案
bash dconf/load_dconf.sh terminal "/org/gnome/terminal/legacy/" "$home_path/dconf/one-half-dark-terminal.dconf"

# 执行默认dconf配置
bash dconf/dconf.sh

rm ~/.vimrc
ln -s ${home_path}/vimrc ~/.vimrc

# w3m浏览器配置
if [[ ! -d "~/.w3m" ]]; then
   mkdir ~/.w3m
fi

rm ~/.w3m/keymap
rm ~/.w3m/config
ln -s ${home_path}/config/w3m-keymap ~/.w3m/keymap
ln -s ${home_path}/config/w3m-config ~/.w3m/config

# python软连接:coc-jedi使用
sudo ln -s /usr/bin/python3 /usr/bin/python
# w3m命令行查看图片
# sudo apt install -y  w3m-inline-image
sudo apt install -y w3m w3m-img
sudo apt install -y nodejs npm
sudo npm install -g n
sudo n stable
sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install -y gcc g++ make cmake

# 下载vim插件
for (( i=0; i<10; i++ ));
do
bash ./vim.git
done

