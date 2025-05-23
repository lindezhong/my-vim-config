#!/bin/bash



# 模板默认方法, 初始化模板时候调用
# 通常来说是如果需要影响到模板需要定义一些全局变量, 有些系统自带的全局变量的作用也只限与这个脚本的方法使用
# 系统的可初始化的变量和作用查看这个脚本的全局变量和这个方法的注释
# :template_path:$1: 模板路径
# :generate_path:$2: 生成目录路径
function config_init() {
    local template_path="$1"
    local generate_path="$2"
    var="测试变量值"
    ignore_path_list[${#ignore_path_list[@]}]='./ignore_file.md'
    ignore_path_list[${#ignore_path_list[@]}]='./${project_name}/ignore_dir'
    only_copy_path_list[${#only_copy_path_list[@]}]='./only_copy_dir'
    only_copy_path_list[${#only_copy_path_list[@]}]='./only_copy.md'
}

# 模板默认方法, 将路径转换为真实路径
# :template_scr_path:$1: 待转换的路径, 会将${template_path}替换成'.'以方便做处理, 如果需要原始的路径需要替换回去
# :template_path:$2: 将要生成的文件路径, 可能会传入文件或目录
# :generate_path:$3: 将要生成的文件路径, 可能会传入文件或目录
# :returns:echo: 转换后的路径,无返回则表示忽略改路径
function convert_real_path() {
    local template_scr_path="$1"
    local template_path="$2"
    local generate_path="$3"
    internal_convert_real_path "$@"

}

# 生成文件/目录前做的事情
# :template_src_path:$1: 将要生成的文件路径, 可能会传入文件或目录
# :generate_target_path:$2: 将要生成的文件路径, 可能会传入文件或目录
function generate_path_before() {
    local template_src_path="$1"
    local generate_target_path="$2"
    echo "before $template_src_path ==> $generate_target_path"
    
}

# 生成文件/目录前后的事情
# :template_src_path:$1: 将要生成的文件路径, 可能会传入文件或目录
# :generate_target_path:$2: 将要生成的文件路径, 可能会传入文件或目录
function generate_path_after() {
    local template_src_path="$1"
    local generate_target_path="$2"
    echo "after  $template_src_path ==> $generate_target_path"
    
}

