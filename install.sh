#!/bin/bash

home_path=`pwd`
rm ~/.vimrc
ln -s ${home_path}/vimrc ~/.vimrc

# 下载vim插件
for (( i=0; i<10; i++ ));
do
bash ./vim.git
done

sudo apt install -y nodejs npm
sudo npm install -g n
sudo n stable
sudo apt install -y python3-pip
sudo apt install -y python3-venv

