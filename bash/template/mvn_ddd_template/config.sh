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
    echo "使用生成文件夹名: [${project_name}] 作为 artifactId"

    read -p "请输入项目名, 默认[${artifact_id}] : " pom_name
    test -z $pom_name && pom_name=${artifact_id}
    echo $pom_name


    database_type_list="mysql mariadb h2"
    read -p "请求输入数据库类型 , 请输入 [${database_type_list}] :  " database_type
    while [[ ! "${database_type_list[@]}" =~ "${database_type}" ]] || [ -z "${database_type}" ]; do
        read -p "请输入 [$database_type_list] : " database_type
    done
   
    if [[ "$database_type" == "mysql" ]]; then
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/data-h2.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/schema-h2.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/data-mariadb.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/schema-mariadb.sql'
    elif [[ "$database_type" == "mariadb" ]]; then
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/data-h2.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/schema-h2.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/data-mysql.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/schema-mysql.sql'
    elif [[ "$database_type" == "h2" ]]; then
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/data-mysql.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/schema-mysql.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/data-mariadb.sql'
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/resources/schema-mariadb.sql'
    fi

    bool_thymeleaf="y n"
    read -p "是否需要模板引擎thymeleaf , 请输入 [${bool_thymeleaf}] :  " is_thymeleaf
    while [[ ! "${bool_thymeleaf[@]}" =~ "${is_thymeleaf}" ]] || [ -z "${is_thymeleaf}" ]; do
        read -p "请输入 [$bool_thymeleaf] : " is_thymeleaf
    done

    if [[ "$is_thymeleaf" == "n" ]]; then
        # 不需要模板引擎忽略文件
        ignore_path_list[${#ignore_path_list[@]}]='./src/main/java/${package_path}/interfaces/verbdemo1/TemplatesController.java'
        ignore_path_list[${#ignore_path_list[@]}]='./src/test/java/${package_path}/interfaces/verbdemo1/TemplatesControllerTest.java'
        
    fi
    
    
    


    # 将 group_id 转换为路径, 比如 com.ldz.demo => com/ldz/demo 
    package_path=${group_id//\./\/}

    
}

