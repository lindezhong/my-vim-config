#!/bin/bash


# 默认值map存储默认值
declare -A default_map=()

####################################
# setuptools init 默认值
####################################
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


ACTION=$1
shift 1

test -z $ACTION && ACTION="--help"

current_path=$(readlink -f $(dirname "$0"))

# 帮助文档
help() {
    echo '
--help : 查看帮助文档
    python.sh --help
    return : 帮助文档信息
    
setuptools : 关于python构建/打包的相关操作, 如果python版本过低需要执行: python.sh setuptools env

    setuptools env : 安装构建/打包的相关依赖
        python.sh setuptools env
        return : pip3安装setuptools wheel twine


    setuptools init : 初始化一个可打包python项目
        python.sh setuptools init {项目名}
        $3 : 项目名,用来创建一个文件夹
        return : 下当前目录下创建一个python项目/文件夹,其中目录结构如下
        {项目名}/
        ├── {项目名}/
        │   ├── __init__.py
        │   └── example.py
        ├── README.md
        ├── pyproject.toml
        ├── setup.py
        └── tests/
            ├── __init__.py
            └── test_example.py

    setuptools instll : 将本地python项目安装到site-packages
        python.sh setuptools install
        return : 在~/.local/lib/python{版本}/site-packages/ 生成文件夹

    setuptools build : 打包本地python项目
        python.sh setuptools build
        return : 在./dist 生成文件夹

    setuptools test : 运行单元测试用例, 等价于 python setup.py test
        python.sh setuptools test {要运行的单元测试python:为空则运行所有的单元测试}
        $1 : 要运行的单元测试python路径,如果为空则运行所有的单元测试, 比如: test/${project_name}/test_${project_name}.py
        return : 运行单元测试结果

    '
}


# 安装构建依赖包,正常无需执行，除非低版本
setuptools_env() {
    python3 -m pip install setuptools wheel twine
}


# python项目初始化/创建一个python项目
setuptools_init() {
    local project_name=$1

    local script_path=$0
    while [ -L $script_path ]; do
        # 如果是软连接要处理真实路径
        script_path=$(ls -al $script_path)
        script_path=${script_path##*->}
    done
    local home_path=$(readlink -f $(dirname "$script_path"))


    while [ -z $project_name ]; do
        read -p "项目名为空,请输入 : " project_name
    done

    if [ -f $project_name ]; then
        echo "当前目录下存在 [$project_name] , 无法初始化python项目"
        return 1
    fi

    read -p "是否为C和Python混合项目, y:是 n:否 , 默认[${default_map["setuptools_init_c_project"]}] : " is_c_project
    test -z "$is_c_project" && is_c_project="${default_map["setuptools_init_c_project"]}"

    mkdir -p $project_name/$project_name
    mkdir -p $project_name/tests
    touch $project_name/README.md
    touch $project_name/requirements.txt
    
    # 初始化setup.cfg文件
    # 元数据有两种类型：静态和动态。
    # 静态元数据（setup.cfg）：保证每次都相同。这更简单，更易于阅读，并且避免了许多常见错误，例如编码错误。
    # 动态元数据 ( setup.py)：可能是不确定的。任何在安装时动态或确定的项目，以及扩展模块或 setuptools 扩展，都需要进入setup.py.
    # setup.cfg应首选静态元数据 ( )。动态元数据 ( setup.py) 应仅在绝对必要时用作逃生舱口。setup.py以前是必需的，但可以在较新版本的 setuptools 和 pip 中省略。
    # setup.cfg是setuptools的配置文件。它告诉 setuptools 您的包（例如名称和版本）以及要包含的代码文件。最终，这种配置中的大部分可能会迁移到pyproject.toml.
    # 项目作者
    local author=${default_map["setuptools_init_author"]}
    # 项目作者email
    local author_email=${default_map["setuptools_init_author_email"]}
    # 项目版本 
    local version=${default_map["setuptools_init_version"]}
    # 项目说明
    local description=${default_map["setuptools_init_description"]}
    # 项目url:默认git
    local url=${default_map["setuptools_init_url"]}
    # 项目依赖的python版本
    local python_version=${default_map["setuptools_init_python_version"]}
    # 项目默认开源协议
    local license=${default_map["setuptools_init_license"]}

    # 项目依赖的第三方包,为数组用空格分割,默认不依赖
    local packages=${default_map["setuptools_init_packages"]}
    read -p "请输入第三方依赖包，使用空格分割: " packages
    # 对于第三方依赖包需要在默认的基础上添加 
    if [[ -z $packages ]]; then
        packages="${default_map['setuptools_init_packages']}"
    else
        packages="$packages ${default_map['setuptools_init_packages']}"
    fi
    # 间第三方依赖包转json "a b" -> ["a", "b"]
    local package_list=()
    if [[ ! -z $packages ]]; then
        package_list=($packages)
    fi
    local i
    for(( i=0; i<${#package_list[@]}; i++)) do
        local item=${package_list[i]}
        # 将第三方依赖包追加到requirements.txt文件为后续install依赖作准备
        # python3 -m pip install -r requirements.txt --index $pypi_index
        echo $item >> $project_name/requirements.txt
    done
    local model=${default_map['setuptools_init_setup_model']}
    if [[ "$model" == "static" ]]; then
        eval "echo \"$(cat ${home_path}/python_project_example_setuptools/setup.cfg)\" > ${project_name}/setup.cfg"
    elif [[ "$model" == "dynamic" ]]; then
        eval "echo \"$(cat ${home_path}/python_project_example_setuptools/setup.py)\" > ${project_name}/setup.py"
    else
        echo "非法的模式 : $model , 需要static或dynamic"
        return -1
    fi
    

    # 初始化 __init__.py 文件
    eval "echo \"$(cat ${home_path}/python_project_example_setuptools/python_project_example_setuptools/__init__.py)\" > $project_name/$project_name/__init__.py"
    eval "echo \"$(cat ${home_path}/python_project_example_setuptools/tests/__init__.py)\" > $project_name/tests/__init__.py"
    # 初始化pyproject.toml文件
    eval "echo \"$(cat ${home_path}/python_project_example_setuptools/pyproject.toml)\" > ${project_name}/pyproject.toml"
    # 初始化example.py文件和相关测试文件test_example.py
    eval "echo \"$(cat ${home_path}/python_project_example_setuptools/python_project_example_setuptools/example.py)\" > $project_name/$project_name/example.py"
    eval "echo \"$(cat ${home_path}/python_project_example_setuptools/tests/test_example.py)\" > $project_name/tests/test_example.py"
    # 如果为C和Python混合项目则创建相关文件
    if [[ $is_c_project == "y" ]]; then
        mkdir -p $project_name/$project_name/api/example
        eval "echo \"$(cat ${home_path}/python_project_example_setuptools/python_project_example_setuptools/api/__init__.py)\" > $project_name/$project_name/api/__init__.py"
        eval "echo \"$(cat ${home_path}/python_project_example_setuptools/python_project_example_setuptools/api/example/c_fun.c)\" > $project_name/$project_name/api/example/c_fun.c"
        eval "echo \"$(cat ${home_path}/python_project_example_setuptools/python_project_example_setuptools/api/example/pybind11.cpp)\" > $project_name/$project_name/api/example/pybind11.cpp"
    fi

}

# 将本地python项目安装到site-packages
setuptools_install() {
    python3 -m pip install .
}

# 打包本地python项目
setuptools_build() {
    python setup.py build
}

# 运行单元测试用例
# $1 : 要运行的单元测试python路径,如果为空则运行所有的单元测试, 比如: test/${project_name}/test_${project_name}.py
setuptools_test() {
    local test_py=$1

    if [[ -z $test_py ]]; then
        read -p "请输入要进行单元测试的python文件路径,如果不输入则默认运行所有单元测试 : " test_py
    fi

    if [[ -z $test_py ]]; then
        python setup.py test
    elif [ ! -f $test_py ]; then
        echo "$test_py 文件不存在请检查"
        exit 1
    else
        python setup.py test -s $test_py
    fi
}



# 关于python构建/打包的相关操作, 如果python版本过低需要执行: python.sh setuptools env
setuptools() {
    local SETUPTOOLS_ACTION=$1

    shift 1

    case $SETUPTOOLS_ACTION in
        env )
            setuptools_env
            ;;
        init )
            setuptools_init $*
            ;;
        install )
            setuptools_install
            ;;
        build )
            setuptools_build
            ;;
        test )
            setuptools_test $*
            ;;
        * )
            echo "参数错误请查看帮助文档, setuptools action is : [$SETUPTOOLS_ACTION]"
            help
            ;;
    esac
}

case $ACTION in
    --help )
        help
        ;;
    setuptools )
        setuptools $*
        ;;
    * )
        echo "未知操作请查看帮助文档"
        help
        ;;
esac

