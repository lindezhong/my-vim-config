#!/bin/bash


ACTION=$1
shift 1
test -z $ACTION && ACTION="--help"

if [[ -z $ACTION ]]; then
    echo "未知操作，请重新输入"
    exit 1
fi

# 帮助文档
function help() {
    echo '
upstream : Git进行fork后跟原仓库同步
    git.sh upstream [{git上游地址:默认去github获取}]
    $2 : fork 前的原仓库地址:默认去github获取
    return : 会添加一个上游的主干分支名称为 : upstream/master

reset : git 回滚相关操作
    
    reset version : git回滚到某个版本  
        git.sh reset version {git_commit_id:}
        如果需要覆盖远程执行 : git push -f , 如果需要放弃回滚 : git pull
        $3: git提交日志id,使用 git log 查看git_commit_id,为空则需要手动输入
        return : git回滚到某个版本
    
    reset add : git撤销add文件(未commit)
        git.sh reset add {file_path_list}
        $3: git文件列表,使用空格分割 比如 a.java b.java
        return: file_path_list取消add

init_server : 初始化git服务端项目,供git clone user@ip:/项目路径
    git.sh init_server {项目名:}
    先决条件:需要开启ssh服务器
    $2 : 项目名,为空需要手动输入
    return : 会在本目录下创建 {项目名}.git 目录

github : github相关操作

    github repos : git clone github上一个组织(organizations)下的所有存储库,比如https://github.com/lindezhong/ 的组织是 lindezhong
        git.sh github repos {github组织} {pageSize:30}
        $3 : 组织(organizations)
        $4 : 可选默认30 github api https://api.github.com/users/USERNAME/repos 每次返回的条数,作为分页结束的条件
        return : clone 组织下的所有存储库
    
    github upstream_url : 解析github项目上游url
        git.sh github upstream_url
        return : github项目上游地址

pull : 将当前目录下的所有git项目pull
    git.sh pull
    return : 当前文件夹下的所有git项目pull
    '
}

# Github进行fork后跟原仓库同步
# :upstream_git_address:$1: git上游地址, 默认去github上获取, 如果github上获取失败需要手动输入
function upstream() {
    local upstream_git_address=$1 

    test -z $upstream_git_address && upstream_git_address=$(github_get_upstream_url)

    if [[ -z $upstream_git_address ]]; then
        echo '请输入上游(fork)git地址,在$2位置'
        exit 1
    fi
    echo "===== $upstream_git_address ====="
    # 先拉取本地最新代码
    git pull

    echo "===== 老git 远程信息 ====="
    # 显示远程仓库信息
    git remote -v


    local upstream_num=$(git remote -v | grep "^upstream" | wc -l)
    if (( upstream_num > 0 )); then
        # 删除上游git
        echo "===== 删除老上游 ====="
        git remote remove upstream
    fi

    # 添加上游git地址
    git remote add upstream $upstream_git_address
   
     echo "===== 新git 远程信息 ====="
    # 查看远程仓库信息
    git remote -v

    # 下载上游git地址
    git fetch upstream

    echo "Git进行fork后跟原仓库同步分支下载完成，新增分支名为 upstream/master (upstream/主干分支名) , 请合并代码: git merge upstream/master"
}

# 解析github上游url
# :return:echo: github上游url
# :return: 1: 解析失败非github项目 , 0: 解析成功 
function github_get_upstream_url() {

    # 判断远程url中origin是否出现github
    local github_url_list=($(git remote -v | grep "^origin" | grep "github.com"))
    
    # 非github项目
    if (( ${#github_url_list[@]} <= 0 )); then
        return 1
    fi

    local github_url=${github_url_list[1]}
    github_url=${github_url#*github.com}
    github_url=${github_url: 1 }

    local github_project_info_json=$(curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${github_url}")

    local parent_github_project_info_json=$(echo $github_project_info_json | jq -r ".parent")
    # 非fork项目
    if [[ -z $parent_github_project_info_json ]]; then
        return 1
    fi
    local upstream_url=$(echo $parent_github_project_info_json | jq -r ".html_url")
    echo $upstream_url
    
    return 0
}


# git clone 一个组织(organizations)下的所有存储库
# :org:$1: github组织(organizations), 比如https://github.com/lindezhong/ 的组织是 lindezhong
function github_repos() {
    local org=$1

    while [ -z $org ]; do
        read -p "组织不允许为空,请输入 : " org
    done
    

    local pageSize=$2
    test -z $pageSize && pageSize="30"

    local repos_index=0
    local repos_url_list=[]
    local currentPageSize=$pageSize
    local pageNum=0

    local git_model
    # git_url(git://开头),的经过测试无法clone下来(一直卡住)不知道是为啥所以不使用
    # 但在git_model_list中保留着, 不做提示
    local git_model_list="clone_url git_url ssh_url"
    read -p "请选择需要clone的url模式,clone_url(http://开头),ssh_url(git@开头) : " -t 60 git_model
    if [[ ! "${git_model_list[@]}" =~ "${git_model}" ]] || [[ -z $git_model ]]; then
        git_model="clone_url"
        echo "git model未知的输入, 默认选择 $git_model 模式"
    fi
    
    
    # 循环请求github获取组织下的所有存储
    while (( $currentPageSize >= $pageSize )); do
        ((pageNum=$pageNum+1))
        local github_org_url_json=$(curl \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/users/${org}/repos?page=${pageNum}")

        currentPageSize=$(echo ${github_org_url_json} | jq ". | length")
        for (( i=0; i<currentPageSize; i++ )); do
            local repos_json=$(echo $github_org_url_json | jq -r ".[$i]")
            local repos_url=$(echo $repos_json | jq -r ".$git_model")
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
    
    for(( i=0;i<${#repos_url_list[@]};i++)) do
        repos_url=${repos_url_list[i]}
        echo "$i) git clone $repos_url"
        local git_dir=${repos_url##*/}
        # 去除最后的 .git
        git_dir=$(echo $git_dir | sed 's/\.git$//g')
        
        git clone $repos_url
        # 如果git clone 报错可能是因为项目已经存在此时进入到该目录中执行git pull
        if [ ! $? -eq 0 ] && [ -d $git_dir ]; then
            pushd $git_dir
            git pull
            popd
        fi
    done;

    return 0
}

# 对github的一些操作, 参数跟返回值查看转发的方法
function github() {
    local GITHUB_ACTION=$1
    case "$GITHUB_ACTION" in
        repos)
            # git clone 一个组织(organizations)下的所有存储库,比如https://github.com/lindezhong/ 的组织是 lindezhong
            # $2 : 组织(organizations)
            # return : clone 组织下的所有存储库
            github_repos $2 $3
            ;;
        upstream_url)
            # 解析github上游url
            # return : git上游地址
            github_get_upstream_url
            ;;
         * )
            echo "未知操作,请查看帮助文档"
            help
            ;;
    esac
}

# git回滚到某个版本
# :commit_id:$1: git 的commit id
function reset_version() {
    local commit_id=$1
    while [ -z $commit_id ]; do
        read -p "git commit_id不允许输入空请重新输入 : " commit_id
    done
    git reset --hard $commit_id
}

# git回滚到某个版本,或取消commit
function reset() {
    local RESET_ACTION=$1
    shift 1
    case "$RESET_ACTION" in
        version )
            reset_version $*
            ;;
        add )
            # git 取消 add文件未cmmit
            git  reset HEAD $*
            ;;
        * )
            echo "未知操作"
            help
            ;;
    esac
}

# 初始化git服务端项目,供git clone user@ip:/项目路径
# :project_name:$1: 项目名
function init_server() {
    local project_name=$1

    while [ -z $project_name ]; do
        read -p "项目名不允许输入空请重新输入 : " project_name
    done

    if ! grep -E '\.git$' <<< "$project_name" >> /dev/null; then
        project_name="${project_name}.git"
    fi

    mkdir -p $project_name
    cd $project_name
    git init --bare

    local current_path=$(pwd)

    echo ""
    echo ""
    echo "请执行git clone命令下项目 : git clone ssh://$USER@localhost:22${current_path}"
}

# 将当前目录下的所有git项目pull
function pull() {
    local dir_list=($(ls -d */))
    local i
    for(( i=0; i<${#dir_list[@]}; i++)) do
        local dir=${dir_list[i]}
        pushd $dir
        git pull
        popd
    done
}

case "$ACTION" in
    --help)
        # 显示帮助文档
        help $*
        ;;
    upstream)
        # Git进行fork后跟原仓库同步
        # $2 : fork 前的原仓库地址
        # return : 会添加一个上游的主干分支名称为 : upstream/master
        upstream $*
        ;;
    github)
        github $*
        ;;
    reset)
        # git回滚到某个版本,或取消add文件
        reset $*
        ;;
    init_server)
        # 初始化git服务端项目,供git clone user@ip:/项目路径
        # $2 : 项目名
        init_server $*
        ;;
    pull)
        # 将当前目录下的所有git项目pull
        pull $*
        ;;
    * )
        echo "未知操作,请查看帮助文档"
        help $*
        ;;
esac

