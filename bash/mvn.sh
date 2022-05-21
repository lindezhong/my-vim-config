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
    mvn clean install -Dmaven.test.skip=true
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

    read -p "请输入运行的class,如果输入空字符串则使用jar中默认指定的main:" class_name


    if [[ -z $class_name ]]; then
        java -jar $jar_path
    else
        java -cp $jar_path $class_name
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

