#!/bin/bash

ACTION=$1

test -z $ACTION && ACTION="--help"


help() {
    echo '
--help: 查看mvn.sh脚本帮助文档

run: 运行maven项目,运行前强制打包编译
    '
}


install() {
    # 不运行测试类，但打包
    mvn clean install -DskipTests=true
    if (( $? != 0 )); then
        echo "mvn编译失败,退出"
        exit 1
    fi
}

run() {

    install

    local jar_path_list=($(find ./ -name "*.jar"))
    local jar_num=${#jar_path_list[@]}

    if (( $jar_num <= 0 )); then
        echo "mvn 编译后找不到jar"
        exit 1
    fi

    local jar_path=${jar_path_list[0]}
    if (( $jar_num > 1 )); then

        for(( i=0;i<${#jar_path_list[@]};i++)) do
            echo "$i) : ${jar_path_list[i]}"
        done;

        read -p "请选择jar:" jar_index
        jar_path=${jar_path_list[$jar_index]}
    fi


    local class_file_path_list=($(grep -r -E "^[[:blank:]]+public[[:blank:]]+static[[:blank:]]+void[[:blank:]]+main" | awk -v FS=":" '{print $1}'))
    local class_file_path="";
    for(( i=0;i<${#class_file_path_list[@]};i++)) do
        class_file_path=${class_file_path_list[i]}
        class_file_path=${class_file_path#*src/main/java/}
        class_file_path=${class_file_path#*src/test/java/}
        class_file_path=${class_file_path//\//.}
        class_file_path=${class_file_path%.java*}
        class_file_path_list[$i]="$class_file_path"
        echo "$i) $class_file_path"
    done

    read -p "请输入运行的class下标或class,如果输入空字符串则使用jar中默认指定的main:" class_index

    if [[ -z $class_index ]]; then
        echo "输入class为空,使用jar指定的main"
    elif grep '^[[:digit:]]$' <<< "$class_index"; then
        class_file_path=${class_file_path_list[class_index]}
        echo "输入class_index: $class_index, class: $class_file_path"
    else
        class_file_path=$class_index
        echo "输入class: $class_file_path"
    fi


    if [[ -z $class_file_path ]]; then
        java -jar $jar_path
    else
        java -cp $jar_path $class_file_path
    fi
    

}

case $ACTION in
    '--help' )
        help
        ;;
    'run' )
        run
        ;;
esac

