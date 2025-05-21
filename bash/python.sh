#!/bin/bash



ACTION=$1
shift 1

test -z $ACTION && ACTION="--help"

current_path=$(readlink -f $(dirname "$0"))

# 帮助文档
function help() {
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
function setuptools_env() {
    python3 -m pip install setuptools wheel twine
}


# python项目初始化/创建一个python项目
# :project_name:$1: 项目名
function setuptools_init() {
    local project_name=$1
    template.sh internal python_project_example_setuptools "$project_name"
}

# 将本地python项目安装到site-packages
function setuptools_install() {
    python3 -m pip install .
}

# 打包本地python项目
function setuptools_build() {
    python setup.py build
}

# 运行单元测试用例
# :test_py:$1: 要运行的单元测试python路径,如果为空则运行所有的单元测试, 比如: test/${project_name}/test_${project_name}.py
function setuptools_test() {
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
# :SETUPTOOLS_ACTION:$1: setuptools相关操作
function setuptools() {
    local SETUPTOOLS_ACTION=$1

    shift 1

    case $SETUPTOOLS_ACTION in
        env )
            setuptools_env "$@"
            ;;
        init )
            setuptools_init "$@"
            ;;
        install )
            setuptools_install "$@"
            ;;
        build )
            setuptools_build "$@"
            ;;
        test )
            setuptools_test "$@"
            ;;
        * )
            echo "参数错误请查看帮助文档, setuptools action is : [$SETUPTOOLS_ACTION]"
            help
            ;;
    esac
}

case $ACTION in
    --help )
        help "$@"
        ;;
    setuptools )
        setuptools "$@"
        ;;
    * )
        echo "未知操作请查看帮助文档"
        help
        ;;
esac

