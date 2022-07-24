# 脚本规范

## 参数规范
1. $1...$n 一定为操作(即前几个参数一定为操作,用来定位到执行那个方法)
2. 如果有默认值使用统一的map:default_map用来储存
3. 如果对于default_map有根据条件是否初始化的要存在defaultMapInit方法进行初始化,如果default_map值修改了也需要调用defaultMapInit
4. 参数名使用下划线格式

## 脚本名命名规范
1. 脚本名称使用下划线
2. 脚本名以 ".sh" 结尾
3. 如果是对莫个shell的增强则命名为shell.sh, 比如 git.sh为对git的增强

### 命名例子
git.sh python.sh mvn.sh 

## 函数名命名规范
***返回值并非shell的return(在shell中return的是这个函数是否执行成功 0: 成功 非0: 失败)***
1. 函数名使用驼峰格式
2. 对于无返回值的不允许使用`_`开头和结尾
3. 对于有返回值并且使用 echo 返回的函数需要使用 `_`(下划线) 开头和结束 如 `_fun_`
4. 对于有返回值并且使用全局变量返回的使用 `_`(下划线)开头,返回的全局变量格式为 `_fun_name_result` 比如 方法 `_fun` 返回值 `_fun_result`

### 函数名命名规范例子
```sh
# 无返回值
fun() {
    # 函数操作逻辑
}

# 使用echo返回
_fun_() {
    # 函数操作逻辑
    # 返回值使用echo返回
    echo "$return"
}

# 使用全局变量返回
_fun() {
    # 函数操作逻辑
    # 返回值使用全局变量返回
    _fun_result="$return"
}
```

## 帮助文档规范
1. 一定要有帮助文档,使用 脚本.sh --help 输出帮助文档
2. 参数中 {提示} 表示外部输入参数非固定
3. 参数中 {提示:默认值} 表示外部输入参数可选,如果不输入则使用默认值
4. 参数{提示:默认值}提示不允许存在空格
5. 参数{提示:}该参数允许不输入,后续会处理

### 帮助文档例子
```sh
help() {
    echo '
upstream : Git进行fork后跟原仓库同步
    git.sh upstream [{git上游地址:默认去github获取}]
    $2 : fork 前的原仓库地址:默认去github获取
    return : 会添加一个上游的主干分支名称为 : upstream/master

reset : git回滚到某个版本  
    git.sh reset {git_commit_id:}
    如果需要覆盖远程执行 : git push -f , 如果需要放弃回滚 : git pull
    $2: git提交日志id,使用 git log 查看git_commit_id,为空则需要手动输入
    return : git回滚到某个版本

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
    
    github upstreamUrl : 解析github项目上游url
        git.sh github upstreamUrl
        return : github项目上游地址
'
}
```
