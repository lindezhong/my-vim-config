# 脚本规范

## 参数规范
1. $1...$n 一定为操作(即前几个参数一定为操作,用来定位到执行那个方法)
2. 如果有默认值使用统一的map:default_map用来储存
3. 如果对于default_map有根据条件是否初始化的要存在defaultMapInit方法进行初始化,如果default_map值修改了也需要调用defaultMapInit

## 命名规范
1. 脚本名称使用下划线
2. 名称名称以 ".sh" 结尾
3. 如果是对莫个shell的增强则命名为shell.sh, 比如 git.sh为对git的增强

### 命名例子
git.sh python.sh mvn.sh 

## 帮助文档规范
1. 一定要有帮助文档,使用 脚本.sh --help 输出帮助文档
2. 参数中 [] 表示可选输入
3. 参数中 {提示} 表示外部输入参数非固定
4. 参数中 {提示:默认值} 表示外部输入参数非固定并且有默认值

### 帮助文档例子
```sh
help() {
    echo '

reset : git回滚到某个版本 
    git.sh reset [{git_commit_id}]
    如果需要覆盖远程执行 : git push -f , 如果需要放弃回滚 : git pull
    $2: git提交日志id,使用 git log 查看git_commit_id,为空则需要手动输入
    return : git回滚到某个版本

github : github相关操作

    github repos : git clone github上一个组织(organizations)下的所有存储库,比如https://github.com/lindezhong/ 的组织是 lindezhong
        git.sh github repos {github 组织} [{pageSize:30}]
        $3 : 组织(organizations)
        $4 : 可选默认30 github api https://api.github.com/users/USERNAME/repos 每次返回的条数,作为分页结束的条件
        return : clone 组织下的所有存储库
    
    github upstreamUrl : 解析github项目上游url
        git.sh github upstreamUrl
        return : github项目上游地址
'
}
```
