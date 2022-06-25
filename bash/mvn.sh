#!/bin/bash

ACTION=$1

test -z $ACTION && ACTION="--help"

declare -A default_map=()
#####################################################################################################################
# java 运行通用默认值 : 正常生成的debug值为: -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005
# transport：监听Socket端口连接方式,常用的dt_socket表示使用socket连接；
# server：=y表示当前是调试服务端，=n表示当前是调试客户端；
# suspend：=n表示启动时不中断；
# address：表示本地监听的地址和端口。
#####################################################################################################################
# 远程debug开关: y:开启 n:关闭
default_map['remote_debug_switch']='y'
# 是否开启服务端debug: y:服务端 n:客户端
default_map['remote_debug_server']='y'
# 远程debug启动时候是否中断 : y:中断 n:不中断
default_map['remote_debug_suspend']='n'
# 远程debug表示监听的地址和端口,例子:0.0.0.0:5005 表示可以接受 ip为0.0.0.0的机器远程debug(如果不填写则不限制ip) ,要连接的端口为 5005
default_map['remote_debug_address']='5005'
# 监听Socket端口连接方式,常用的dt_socket表示使用socket连接
default_map['remote_debug_transport']='dt_socket'
# 开放远程debug端口
default_map['remote_debug_port']='5005'


# 初始默认值,如果有default_map改变需要重新调用
defaultMapInit() {
    if [[ "${default_map['remote_debug_switch']}" == "y" ]]; then
        # 正常使用该值在java运行参数上即可
        default_map['remote_debug']="-agentlib:jdwp=transport=${default_map['remote_debug_transport']},server=${default_map['remote_debug_server']},suspend=${default_map['remote_debug_suspend']},address=${default_map['remote_debug_address']}"
    fi

}

defaultMapInit


help() {
    echo '
--help: 查看mvn.sh脚本帮助文档

deploy: 运行maven项目,运行前强制打包编译
    mvn.sh deploy [{class过滤字符:默认不过滤}]
    $2 : class过滤字符:默认不过滤
    return: 打包运行maven项目

run: 运行maven项目,只是编译不打包,开启远程debug,远程端口5005,不阻塞启动
    mvn.sh run [{class过滤字符:默认不过滤}]
    如果为spring boot 项目需要先执行mvn clean install,将resource下的资源打包,编译无法打包resource下的资源
    $2 : class过滤字符:默认不过滤
    return: 编译运行maven项目

debug: 运行maven项目,只是编译不打包,开启远程debug,远程端口5005,阻塞启动
    mvn.sh debug [{class过滤字符:默认不过滤}]
    如果为spring boot 项目需要先执行mvn clean install,将resource下的资源打包,编译无法打包resource下的资源
    $2 : class过滤字符:默认不过滤
    return: 编译运行maven项目

find_main: 扫描本目录下所有的main java
    mvn.sh find_main [{路径中要包含的字符:默认不过滤}] [{路径中要包含的字符:默认不过滤}]
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

selectClass() {

    local filter_class=$1

    local class_file_path=''
    local class_file_path_list=($(findMainClass "src/main" $filter_class))
    for(( i=0;i<${#class_file_path_list[@]};i++)) do
        class_file_path=${class_file_path_list[i]}
        echo "$i) $class_file_path"
    done

    local class_index
    read -p "请输入运行的class下标或class,如果输入空字符串则使用jar中默认指定的main: " class_index

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

    _select_class_result=$class_file_path

}

deploy() {

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

    selectClass $filter_class
    local class_file_path=$_select_class_result

    if [[ -z $class_file_path ]]; then
        java ${default_map['remote_debug']} -jar $jar_path
    else
        java ${default_map['remote_debug']} -cp $jar_path $class_file_path
    fi
    

}

run() {
    local filter_class=$1
    mvn compiler:compile
    local class_path_list=($(find ./ -name "classes" | grep "/target/classes"))
    
    local class_path=""
    local i
    for(( i=0; i<${#class_path_list[@]}; i++)) do
        local class_path_item=${class_path_list[i]}
        if (( i>0 )); then
            class_path=":${class_path}"
        fi
        class_path="${class_path_item}${class_path}"
    done

    # 查找maven依赖的jar
    local mvn_jar_path_list=($(mvn dependency:build-classpath | grep -v "Download" | grep -v "INFO" | grep -v "WARNING" | grep -v "ERROR" | grep "jar"))
    local mvn_jar_path_list_length=${#main_class_path_list[@]}

    if (( mvn_jar_path_list_length > 1)); then
        echo "找到数量不对的maven jar路径,mvn jar 路径数量:[$mvn_jar_path_list_length],请检查"
        local mvn_jar_path_list_index
        for(( mvn_jar_path_list_index=0; mvn_jar_path_list_index<${#mvn_jar_path_list[@]}; mvn_jar_path_list_index++)) do
            local mvn_jar_path=${mvn_jar_path_list[mvn_jar_path_list_index]}
            echo "$mvn_jar_path_list_index) $mvn_jar_path"
        done
    fi

    local use_mvn_jar_path=$mvn_jar_path_list
    if [[ ! -z $use_mvn_jar_path ]]; then
        use_mvn_jar_path=":$use_mvn_jar_path"
    fi

    echo "使用的maven jar path : [$use_mvn_jar_path]"
    echo "使用class_path : [${class_path}]"

    selectClass $filter_class
    local main_class_path=$_select_class_result
    java ${default_map['remote_debug']} -classpath ${class_path}${use_mvn_jar_path} $main_class_path
}

case $ACTION in
    '--help' )
        help
        ;;
    'deploy' )
        deploy "$2"
        ;;
    'run' )
        run "$2"
        ;;
    'debug' )
        default_map['remote_debug_suspend']='y'
        defaultMapInit
        run "$2"
        ;;
    'find_main' )
        findMainClass "$2" "$3"
        ;;
    * )
        echo "未知操作"
        ;;
esac

