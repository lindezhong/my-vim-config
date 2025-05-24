#!/bin/bash

####################################
# setuptools init 默认值
####################################
declare -A default_map=()
# 项目作者
default_map["setuptools_init_author"]="ldz"
# 项目作者email
default_map["setuptools_init_author_email"]="2872611588@qq.com"
# 项目版本 
default_map["setuptools_init_version"]="0.0.1"
# 项目说明
default_map["setuptools_init_description"]="A small example package"
# 项目url:默认git
default_map["setuptools_init_url"]="https://github.com/lindezhong"
# 项目依赖的python版本
default_map["setuptools_init_python_version"]="3.6"
# 项目依赖的第三方包,为数组用空格分割,默认不依赖,后续输入以追加形式存在,不会覆盖默认值
default_map["setuptools_init_packages"]=""
# 项目默认开源协议
default_map["setuptools_init_license"]="MIT License"
# 项目默认元数据配置. dynamic : setup.py , static : setup.cfg
default_map["setuptools_init_setup_model"]="dynamic"
# 是否为C和Python混合项目, y:是 n:否
default_map["setuptools_init_c_project"]="n"



# 模板默认方法, 初始化模板时候调用
# :template_path:$1: 模板路径
# :generate_path:$2: 生成目录路径
function config_init() {
    local template_path="$1"
    local generate_path="$2"
    if [ -d $generate_path ]; then
        echo "[$generate_path]目录已经存在 , 无法初始化python项目"
        exit 1
    fi


    # 初始化setup.cfg文件
    # 元数据有两种类型：静态和动态。
    # 静态元数据（setup.cfg）：保证每次都相同。这更简单，更易于阅读，并且避免了许多常见错误，例如编码错误。
    # 动态元数据 ( setup.py)：可能是不确定的。任何在安装时动态或确定的项目，以及扩展模块或 setuptools 扩展，都需要进入setup.py.
    # setup.cfg应首选静态元数据 ( )。动态元数据 ( setup.py) 应仅在绝对必要时用作逃生舱口。setup.py以前是必需的，但可以在较新版本的 setuptools 和 pip 中省略。
    # setup.cfg是setuptools的配置文件。它告诉 setuptools 您的包（例如名称和版本）以及要包含的代码文件。最终，这种配置中的大部分可能会迁移到pyproject.toml.
    # 项目作者
    author=${default_map["setuptools_init_author"]}
    # 项目作者email
    author_email=${default_map["setuptools_init_author_email"]}
    # 项目版本 
    version=${default_map["setuptools_init_version"]}
    # 项目说明
    description=${default_map["setuptools_init_description"]}
    # 项目url:默认git
    url=${default_map["setuptools_init_url"]}
    # 项目依赖的python版本
    python_version=${default_map["setuptools_init_python_version"]}
    # 项目默认开源协议
    license=${default_map["setuptools_init_license"]}

    read -p "是否为C和Python混合项目, y:是 n:否 , 默认[${default_map["setuptools_init_c_project"]}] : " is_c_project
    test -z "$is_c_project" && is_c_project="${default_map["setuptools_init_c_project"]}"
    # 忽略的文件列表
    ignore_path_list=()
    local model=${default_map['setuptools_init_setup_model']}
    if [[ "$model" == "static" ]]; then
        ignore_path_list[${#ignore_path_list[@]}]="./setup.py"
    elif [[ "$model" == "dynamic" ]]; then
        ignore_path_list[${#ignore_path_list[@]}]="./setup.cfg"
    else
        echo "非法的模式 : $model , 需要static或dynamic"
        exit -1
    fi

     # 如果为C和Python混合项目则创建相关文件
    if [[ $is_c_project != "y" ]]; then
        # 忽略api下所有目录
        ignore_path_list[${#ignore_path_list[@]}]='./${project_name}/api'
    fi



}


