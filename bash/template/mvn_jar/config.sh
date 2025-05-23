#!/bin/bash

# 模板默认方法, 初始化模板时候调用
# 通常来说是如果需要影响到模板需要定义一些全局变量, 有些系统自带的全局变量的作用也只限与这个脚本的方法使用
# 系统的可初始化的变量和作用查看这个脚本的全局变量和这个方法的注释
# :template_path:$1: 模板路径
# :generate_path:$2: 生成目录路径
function config_init() {
    local template_path="$1"
    local generate_path="$2"

    read -p "请输入groupId,如果输入空则默认使用 [com.ldz.demo]  :" group_id
    test -z "$group_id" && group_id="com.ldz.demo"

    artifact_id="$project_name"
    echo "使用项目名: [${project_name}] 作为 artifactId"


    # 将 group_id 转换为路径, 比如 com.ldz.demo => com/ldz/demo 
    package_path=${group_id//\./\/}

    
}

