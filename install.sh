#!/bin/bash

home_path=`pwd`
rm ~/.vimrc
ln -s ${home_path}/vimrc ~/.vimrc

# 下载vim插件
bash ./vim.git

sudo apt install -y nodejs npm
sudo npm install -g n
sudo n stable

