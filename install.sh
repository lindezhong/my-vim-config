#!/bin/bash

home_path=$(readlink -f $(dirname "$0"))
# 配置ubuntu终端颜色方案
bash dconf/load_dconf.sh terminal "/org/gnome/terminal/legacy/" "$home_path/dconf/one-half-dark-terminal.dconf"

# 执行默认dconf配置
bash dconf/dconf.sh

rm ${HOME}/.vimrc
ln -s ${home_path}/vimrc ${HOME}/.vimrc

# w3m浏览器配置
if [ ! -d ${HOME}/.w3m ]; then
    mkdir ${HOME}/.w3m
fi


if [ -f ${HOME}/.w3m/keymap ]; then
    rm ${HOME}/.w3m/keymap
fi
if [ -f ${HOME}/.w3m/config ]; then
    rm ${HOME}/.w3m/config
fi
ln -s ${home_path}/config/w3m-keymap ${HOME}/.w3m/keymap
ln -s ${home_path}/config/w3m-config ${HOME}/.w3m/config

# 将./bash 下的文件软连接到 ~/.local/bin
if [ ! -d ${HOME}/.local/bin ]; then
    mkdir -p ${HOME}/.local/bin
fi
for sh_file_path in $home_path/bash/*.sh ; do
    target_ln_path="${HOME}/.local/bin/${sh_file_path##*/}"
    if [ -f $target_ln_path ]; then
        rm $target_ln_path
    fi
    ln -s $sh_file_path $target_ln_path
done

# 配置,shell tab 提示
sudo ln -s ${home_path}/bash/bash_completion /etc/bash_completion.d


# python软连接:coc-jedi使用
if [ ! -f /usr/bin/python ]; then
    sudo ln -s /usr/bin/python3 /usr/bin/python
fi
# w3m命令行查看图片
# sudo apt install -y  w3m-inline-image
sudo apt install -y w3m w3m-img

sudo apt install -y jq
sudo apt install -y nodejs npm
sudo npm install -g n
sudo n stable
sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install -y gcc g++ make cmake


#####################################################
####     可选安装(由自己执行这里只是作记录)      ####
#####################################################

# 爬取视频工具
# pip3 install you-get
# sqlite3
# sudo apt install -y sqlite3 sqlite3-doc

#####################################################
####     可选安装(由自己执行这里只是作记录)      ####
#####################################################


# 下载vim插件
for (( i=0; i<10; i++ )); do
bash ./vim.git
done

# 安装debug支持
for (( i = 0; i < 10; i++ )); do
    ./bundle/vimspector/install_gadget.py --all
    ./bundle/vimspector/install_gadget.py --force-enable-java
done
