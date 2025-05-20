# 查看帮助文档
git.sh --help
# Git进行fork后跟原仓库同步,会添加一个上游的主干分支 upstream/master
git.sh upstream {上游git地址}
# git clone github上一个组织(organizations)下的所有存储库
git.sh github repos {github组织} {pageSize:30}
# 解析github项目上游url
git.sh github upstreamUrl
# git回滚到某个版本
git.sh reset version {git_commit_id}
# git撤销add 文件列表
git.sh reset add {cmd:comp_file_direct}
# 初始化git服务端项目,供git clone user@ip:/项目路径
git.sh init_server {项目名}
# 将当前目录下的所有git项目pull
git.sh pull
