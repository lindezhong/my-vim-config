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

github repos : git clone github上一个组织(organizations)下的所有存储库,比如https://github.com/lindezhong/ 的组织是 lindezhong
    git.sh github repos ${github 组织} [${pageSize:30}]

    $3 : 组织(organizations)
    $4 : 可选默认30 github api https://api.github.com/users/USERNAME/repos 每次返回的条数,作为分页结束的条件
    return : clone 组织下的所有存储库

    '
}

# Github进行fork后跟原仓库同步
upstream() {
    local upstream_git_address=$1 
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

    echo "Git进行fork后跟原仓库同步分支下载完成，新增分支名为 upstream/master (upstream/主干分支名) , 请合并代码: git merge upstream/master"
}

# git clone 一个组织(organizations)下的所有存储库,比如https://github.com/lindezhong/ 的组织是 lindezhong
githubRepos() {
    local org=$1
    local pageSize=$2
    test -z $pageSize && pageSize="30"

    local repos_index=0
    local repos_url_list=[]
    local currentPageSize=$pageSize
    local pageNum=0
    
    # 循环请求github获取组织下的所有存储
    while (( $currentPageSize >= $pageSize )); do
        ((pageNum=$pageNum+1))
        local github_org_url_json=$(curl \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/users/${org}/repos?page=${pageNum}")

        currentPageSize=$(echo ${github_org_url_json} | jq ". | length")
        for (( i=0; i<currentPageSize; i++ )); do
            local repos_json=$(echo $github_org_url_json | jq -r ".[$i]")
            local repos_url=$(echo $repos_json | jq -r ".html_url")
            repos_url_list[$repos_index]=$repos_url
            ((repos_index=$repos_index+1))
        done
    done
    
    # 打印所有的存储库
    echo -e "\n\n===== show git repos_url =====\n\n"

    for(( i=0;i<${#repos_url_list[@]};i++)) do
        repos_url=${repos_url_list[i]}
        echo "$i) $repos_url"
    done;

    echo -e "\n\n===== git clone repos_url =====\n\n"

    for repos_url in "${repos_url_list[@]}"; do
        git clone $repos_url
    done

}

# 对github的一些操作
github() {
local GITHUB_ACTION=$1
case "$GITHUB_ACTION" in
    repos)
        # git clone 一个组织(organizations)下的所有存储库,比如https://github.com/lindezhong/ 的组织是 lindezhong
        # $2 : 组织(organizations)
        # return : clone 组织下的所有存储库
        githubRepos $2 $3
        ;;
esac
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
    github)
        # 对github的一些操作,多传递一些参数防止不够用
        github "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
        ;;
esac

