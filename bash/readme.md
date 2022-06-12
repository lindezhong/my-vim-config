# 脚本规范

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
