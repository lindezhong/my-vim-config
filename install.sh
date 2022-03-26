#!/bin/bash

home_path=`pwd`
ln -s ${home_path}/vimrc ~/.vimrc

# 下载vim插件
bash ./vim.git


