#!/bin/bash

home_path=$(readlink -f $(dirname "$0"))


# ~/.vim/autoload/它是一个非常重要的目录，尽管听起来比实际复杂。简而言之，它里面放置的是当你真正需要的时候才被自动加载运行的文件，而不是在vim启动时就加载。
# ~/.vim/colors/是用来存放vim配色方案的。
# ~/.vim/plugin/存放的是每次启动vim都会被运行一次的插件，也就是说只要你想在vim启动时就运行的插件就放在这个目录下。我们可以放从vim-plug官方下载下来的插件.vim
# ~/.vim/syntax/语法描述脚本。我们放有关文本（比如c语言）语法相关的插件
# ~/.vim/doc/为插件放置文档的地方。例如:help的时候可以用到。
# ~/.vim/ftdetect/中的文件同样也会在vim启动时就运行。有些时候可能没有这个目录。ftdetect代表的是“filetype detection（文件类型检测）”。此目录中的文件应该用自动命令（autocommands）来检测和设置文件的类型，除此之外并无其他。也就是说，它们只该有一两行而已。
# ~/.vim/ftplugin/此目录中的文件有些不同。当vim给缓冲区的filetype设置一个值时，vim将会在~/.vim/ftplugin/ 目录下来查找和filetype相同名字的文件。例如你运行set filetype=derp这条命令后，vim将查找~/.vim/ftplugin/derp.vim此文件，如果存在就运行它。不仅如此，它还会运行ftplugin下相同名字的子目录中的所有文件，如~/.vim/ftplugin/derp/这个文件夹下的文件都会被运行。每次启用时，应该为不同的文件类型设置局部缓冲选项，如果设置为全局缓冲选项的话，将会覆盖所有打开的缓冲区。
# ~/.vim/indent/这里面的文件和ftplugin中的很像，它们也是根据它们的名字来加载的。它放置了相关文件类型的缩进。例如python应该怎么缩进，java应该怎么缩进等等。其实放在ftplugin中也可以，但单独列出来只是为了方便文件管理和理解。
# ~/.vim/compiler/和indent很像，它放的是相应文件类型应该如何编译的选项。
# ~/.vim/after/这里面的文件也会在vim每次启动的时候加载，不过是等待~/.vim/plugin/加载完成之后才加载after里的内容，所以叫做after。
# ~/.vim/spell/拼写检查脚本。
# 安装Vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 创建mksession目录用于自动保存mksession
mkdir -p ~/.vim-session

# 顺带兼容 nvim
# nvim vim-plug
mkdir -p ~/.local/share/nvim/site/autoload
ln -s ~/.vim/autoload/plug.vim ~/.local/share/nvim/site/autoload/
# vim 配置链接
mkdir -p ~/.config/nvim/
ln -s ~/.vim/vimrc ~/.config/nvim/init.vim

# nvim配色方案链接
# 由于~/.config/nvim/colors/目录的配色方案优先所以可以覆盖默认的配色方案
mkdir -p ~/.config/nvim/colors
ln -s ~/.vim/colors/vimdefault.vim ~/.config/nvim/colors/default.vim


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
ln -s ${home_path}/keymap/w3m-keymap ${HOME}/.w3m/keymap
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
if [ ! -d ~/.bash_completion ]; then
    ln -s ${home_path}/bash/bash_completion_tips ~/.bash_completion
fi


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

# LeaderF 搜索目录依赖
sudo apt install -y ripgrep

#####################################################
####     可选安装(由自己执行这里只是作记录)      ####
#####################################################

# 爬取视频工具
# pip3 install you-get

# sqlite3
# sudo apt install -y sqlite3 sqlite3-doc

# plantuml 依赖 Graphviz
# sudo apt install -y graphviz  graphviz-doc

#####################################################
####     可选安装(由自己执行这里只是作记录)      ####
#####################################################


# # 下载vim插件
# for (( i=0; i<10; i++ )); do
# bash ./vim.git
# done
# 
# # 安装debug支持
# for (( i = 0; i < 10; i++ )); do
#     ./bundle/vimspector/install_gadget.py --all
#     ./bundle/vimspector/install_gadget.py --force-enable-java
# done
