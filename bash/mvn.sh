#!/bin/bash

ACTION=$1

test -z $ACTION && ACTION="--help"


help() {
    echo '
--help: 查看mvn.sh脚本帮助文档

run: 运行maven项目,运行前强制打包编译
    mvn.sh run [{class过滤字符:默认不过滤}]
    
    $2 : class过滤字符:默认不过滤
    return: 打包运行maven项目

find_main: 扫描本目录下所有的main java
    mvn.s find_main [{路径中要包含的字符:默认不过滤}] [{路径中要包含的字符:默认不过滤}]

    $2: 路径中要包含的字符,默认不过滤,一般为src/main或src/test 用来区分是否为测试类
    $3: 路径中要包含的字符,默认不过滤,一般为类名
    return 本目录下所有的main java全路径(package.class_name)
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

findMainClass() {

    
    local filter_class1=$1
    local filter_class2=$2

    local class_file_path_list=($(grep -r -E "^[[:blank:]]+public[[:blank:]]+static[[:blank:]]+void[[:blank:]]+main" | awk -v FS=":" '{print $1}' | grep "$filter_class1" | grep "$filter_class2"))
    local class_file_path_list_txt=""
    local class_file_path=""
    for(( i=0;i<${#class_file_path_list[@]};i++)) do
        class_file_path=${class_file_path_list[i]}
        class_file_path=${class_file_path#*src/main/java/}
        class_file_path=${class_file_path#*src/test/java/}
        class_file_path=${class_file_path//\//.}
        class_file_path=${class_file_path%.java*}

        class_file_path_list_txt="$class_file_path_list_txt $class_file_path"
    done
    echo $class_file_path_list_txt

}

run() {

    local filter_class=$1
    
    install

    local jar_path_list=($(find ./ -name "*.jar" | grep -v "/lib"))
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
        while [ -z `grep -E '^[0-9][0-9]*$' <<< "$jar_index"` ] || [ $jar_index -lt 0 ] || [ $jar_index -gt ${#jar_path_list[@]} ]; do
            read -p "请输入正确的jar下标 : [0 , ${#jar_path_list[@]}-1] : " jar_index
        done
        jar_path=${jar_path_list[$jar_index]}
    fi

    local class_file_path=''
    local class_file_path_list=($(findMainClass "src/main" $filter_class))
    for(( i=0;i<${#class_file_path_list[@]};i++)) do
        class_file_path=${class_file_path_list[i]}
        echo "$i) $class_file_path"
    done

    
    read -p "请输入运行的class下标或class,如果输入空字符串则使用jar中默认指定的main:" class_index

    if [[ -z $class_index ]]; then
        echo "输入class为空,使用jar指定的main"
    elif grep '^[[:digit:]]*$' <<< "$class_index"; then
        class_file_path=${class_file_path_list[class_index]}
        echo "输入class_index: $class_index, class: $class_file_path"
    else
        class_file_path=$class_index
        echo "输入class: $class_file_path"
    fi
    
    
    echo ""
    echo ""
    echo "select index is [$class_index] , class file path is [$class_file_path]"
    echo ""
    echo ""

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
        run "$2"
        ;;
    'find_main' )
        findMainClass "$2" "$3"
        ;;
    * )
        echo "未知操作"
        ;;
esac

