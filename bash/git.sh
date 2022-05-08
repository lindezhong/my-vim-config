#!/bin/bash


ACTION=$1
test -z $ACTION && ACTION="--help"

if [[ -z $ACTION ]]; then
    echo "未知操作，请重新输入"
    exit 1
fi

help() {
    echo '
upstream : Git进行fork后跟原仓库同步
    git.sh upstream ${git上游地址}

    $2 : fork 前的原仓库地址
    return : 会添加一个上游的主干分支名称为 : upstream/master
    '
}

# Github进行fork后跟原仓库同步
upstream() {
    upstream_git_address=$1 
    if [[ -z $upstream_git_address ]]; then
         echo '请输入上游(fork)git地址,在$2位置'
         exit 1
    fi
    echo "$upstream_git_address ========"
    # 先拉取本地最新代码
    git pull

    # 显示远程仓库信息
    git remote -v


    # 删除上游git
    git remote remove upstream

    # 添加上游git地址
    git remote add upstream $upstream_git_address
   
    # 查看远程仓库信息
    git remote -v

    # 下载上游git地址
    git fetch upstream

    echo "Git进行fork后跟原仓库同步分支下载完成，新增分支名为 upstream/master (upstream/主干分支名) , 请合并代码"
}

case "$ACTION" in
    --help)
        # 显示帮助文档
        help
    ;;
    upstream)
        # Git进行fork后跟原仓库同步
        # $2 : fork 前的原仓库地址
        # return : 会添加一个上游的主干分支名称为 : upstream/master
        upstream "$2"
    ;;
esac

