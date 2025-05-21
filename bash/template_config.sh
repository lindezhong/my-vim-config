#!/bin/bash



# 模板默认方法, 初始化模板时候调用
function config_init() {
    echo ""
}

# 模板默认方法, 将路径转换为真实路径
# :$1: 待转换的路径
# :returns:echo: 转换后的路径,无返回则表示忽略改路径
function convert_real_path() {
    eval echo "$1"
}

# 生成文件/目录前做的事情
# :template_path:$1: 将要生成的文件路径, 可能会传入文件或目录
# :generate_path:$2: 将要生成的文件路径, 可能会传入文件或目录
function generate_path_before() {
    local template_path="$1"
    local generate_path="$2"
    # echo "before $template_path ==> $generate_path"
    
}

# 生成文件/目录前后的事情
# :template_path:$1: 将要生成的文件路径, 可能会传入文件或目录
# :generate_path:$2: 将要生成的文件路径, 可能会传入文件或目录
function generate_path_after() {
    local template_path="$1"
    local generate_path="$2"
    # echo "after  $template_path ==> $generate_path"
    
}

