# 脚本规范

## 参数规范
1. $1...$n 一定为操作(即前几个参数一定为操作,用来定位到执行那个方法)
2. 如果有默认值使用统一的map:default_map用来储存
3. 如果对于default_map有根据条件是否初始化的要存在default_map_init方法进行初始化,如果default_map值修改了也需要调用default_map_init
4. 参数名使用下划线格式
5. 如果调用方法需要传递 $1...$n 的参数则尽量使用 `"$@"` (这样能正确传递参数), 配合 shitf n 可以去除不要的参数

## 脚本名命名规范
1. 脚本名称使用下划线
2. 脚本名以 ".sh" 结尾
3. 如果是对莫个shell的增强则命名为shell.sh, 比如 git.sh为对git的增强

### 命名例子
git.sh python.sh mvn.sh 

## 函数名命名规范
***返回值并非shell的return(在shell中return的是这个函数是否执行成功 0: 成功 非0: 失败)***
1. 函数名使用小写下划线格式
2. 对于方法需要有注释, 需要在注释中表明参数和返回值, 注释例子如下
```shell
# 方法说明, 可以通过vim snippets 的 fun 关键字快速生成对应格式的方法
# :var_name:$args_index: var_name为从方法参数获取的变量名, $args_index 为从那个方法参数上获取, 例子 :var:$1:
# :return:echo: 这种格式表明是通过 echo "返回值" 格式返回的
# :return:return_var: 这种格式表明是通过全局变量返回的,并且该全局变量名为 return_var
#                     这种格式本质上是是说这个方法影响了这个全局变量, 一个方法可以有多少这种return
#                     如果return_var格式为 ${function_name}_result , 即表明是这个方法的返回值, 为调用方法后立即需要使用, 不做持久化
# :return: 这种格式说明是通过 return 返回的, 只能返回数字 
function function_name() {
    local var="$1"
    ... 
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
    
    github upstream_url : 解析github项目上游url
        git.sh github upstream_url
        return : github项目上游地址
'
}
```
