#!/bin/bash

ACTION=$1
shift 1

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


#####################################################################################################################
# maven初始化默认值
#####################################################################################################################
# maven默认group_id
default_map['init_maven_group_id']='com.ldz.demo'

# 初始默认值,如果有default_map改变需要重新调用
# :return:default_map: 初始化默认值
function default_map_init() {
    if [[ "${default_map['remote_debug_switch']}" == "y" ]]; then
        # 正常使用该值在java运行参数上即可
        default_map['remote_debug']="-agentlib:jdwp=transport=${default_map['remote_debug_transport']},server=${default_map['remote_debug_server']},suspend=${default_map['remote_debug_suspend']},address=${default_map['remote_debug_address']}"
    fi

}

default_map_init

# 帮助文档
function help() {
    echo '
--help : 查看mvn.sh脚本帮助文档

deploy : 部署maven项目,运行前强制打包编译
    mvn.sh deploy {class过滤字符:默认不过滤}
    $2 : class过滤字符:默认不过滤
    return : 打包运行maven项目

run : 运行maven项目,只是编译不打包,开启远程debug,远程端口5005,不阻塞启动
    mvn.sh run {class过滤字符:默认不过滤}
    如果为spring boot 项目需要先执行mvn clean install,将resource下的资源打包,编译无法打包resource下的资源
    $2 : class过滤字符:默认不过滤
    return : 编译运行maven项目

debug : 运行maven项目,只是编译不打包,开启远程debug,远程端口5005,阻塞启动
    mvn.sh debug {class过滤字符:默认不过滤}
    如果为spring boot 项目需要先执行mvn clean install,将resource下的资源打包,编译无法打包resource下的资源
    $2 : class过滤字符:默认不过滤
    return: 编译运行maven项目

find_main : 扫描本目录下所有的main java
    mvn.sh find_main {路径中要包含的字符:默认不过滤} {路径中要包含的字符:默认不过滤}
    $2: 路径中要包含的字符,默认不过滤,一般为src/main或src/test 用来区分是否为测试类
    $3: 路径中要包含的字符,默认不过滤,一般为类名, 如果过滤字符包含模块名会被去除比如 module_name/com.class_name -> com.class_name
    return 本目录下所有的main 模块名/java全路径(module_name/package.class_name)

init : 初始化maven项目

    init jar : 初始化普通maven项目, 打包为jar
        mvn.sh init jar
        在运行过程中需要手动输入 groupId 和 artifactId
        return : 在本地会创建一个 artifactId 的maven项目
    '
}

# 编译mvn项目,跳过测试类(只编译不打包)
# :return: 1: 编译失败
function install() {
    # 不运行测试类，但打包
    mvn clean install  -Dmaven.test.skip=true
    if (( $? != 0 )); then
        echo "mvn编译失败,退出"
        exit 1
    fi
}

# 扫描本目录下所有的main java
# :filter_class1:$1: 过滤类列表字符串1
# :filter_class2:$2: 过滤类列表字符串2
# :return:echo: main java的类路径比如 com.ldz.Main
function find_main_class() {


    local filter_class1=$1
    local filter_class2=$2

    local class_file_path_list=($(find ./ -name "*.java" | xargs grep -E "^[[:blank:]]+public[[:blank:]]+static[[:blank:]]+void[[:blank:]]+main" | awk -v FS=":" '{print $1}' | grep "$filter_class1" | grep "$filter_class2"))
    local class_file_path_list_txt=""
    local class_file_path=""
    for(( i=0;i<${#class_file_path_list[@]};i++)) do
        class_file_path=${class_file_path_list[i]}
        local module_name_path=$class_file_path

        class_file_path=${class_file_path#*src/main/java/}
        class_file_path=${class_file_path#*src/test/java/}
        class_file_path=${class_file_path//\//.}
        class_file_path=${class_file_path%.java*}


        module_name_path=${module_name_path%%/src/main/java/*}
        module_name_path=${module_name_path%%/src/main/java/*}
        module_name_path=${module_name_path/\./}
        module_name_path=${module_name_path/\//}

        if [[ ! -z $module_name_path ]]; then
            # 如果模块名不为空说明是子模块的类,类路径需要添加上模块名
            class_file_path="${module_name_path}/$class_file_path"
        fi

        class_file_path_list_txt="$class_file_path_list_txt $class_file_path"
    done
    echo $class_file_path_list_txt

}

# 选择main java,需要先扫描main java(执行 find_main_class)
# :filter_class1:$1: 过滤类列表字符串1
# :filter_class2:$2: 过滤类列表字符串2
# :return:select_class_result: 选择后的class name
function select_class() {

    local filter_class1=$1
    local filter_class2=$2

    # 对于第二个参数需要去除模块名
    filter_class2=${filter_class2##*/}

    local class_file_path=''
    local class_file_path_list=($(find_main_class "$filter_class1" "$filter_class2"))
    local class_file_path_list_langth=${#class_file_path_list[@]}


    if  [[ ! -z $filter_class2 ]] && (( $class_file_path_list_langth == 1  )) ; then
        # 如果存在过滤, 并且过滤后只有一个类说明过滤成功则直接结束
        select_class_result=${class_file_path_list[0]}
        return 0
    fi

    local i
    while /bin/true; do
        for(( i=0;i<$class_file_path_list_langth;i++)) do
            class_file_path=${class_file_path_list[i]}
            if grep "$class_index" <<< "$class_file_path" >> /dev/null; then
                echo "$i) $class_file_path"
            fi
        done

        # 重置class_file_path防止数据污染
        class_file_path=""

        read -p "请输入运行的class下标或class(用来过滤class),如果输入'-1'则使用jar中默认指定的main: " class_index

        if grep -E '^[-0-9][0-9]*$' <<< "$class_index" >> /dev/null; then
            if (( class_index >=0 && class_index < class_file_path_list_langth )); then
                class_file_path=${class_file_path_list[class_index]}
                echo "输入class_index: $class_index, class: $class_file_path"
                break
            elif [ "$class_index" -lt "0" ]; then
                echo "输入class_index为负数,使用jar指定的main"
                class_file_path=""
                break
            fi
        fi

    done


    echo ""
    echo ""
    echo "select index is [$class_index] , class file path is [$class_file_path]"
    echo ""
    echo ""

    select_class_result=$class_file_path

}

# 部署maven项目,运行前强制打包编译
# :filter_class:$1: 运行的class过滤字符串
function deploy() {

    local filter_class=$1

    install

    select_class "src/main" $filter_class
    local class_file_path=$select_class_result


    local module_name_path=${class_file_path%/*}
    if [[ ! -z $module_name_path ]]; then
        # 如果模块名不为空, 即main_class_path中有 '/' 需要重新处理 main_class_path, 并且进入模块目录
        class_file_path=${class_file_path##*/}
        echo "进入模块 $module_name_path , 主类为 $class_file_path"
        pushd $module_name_path
    fi

    local jar_path_list=($(find ./ -name "*.jar" | grep -v "/lib"))
    local jar_num=${#jar_path_list[@]}

    if (( $jar_num <= 0 )); then
        echo "mvn 编译后找不到jar"
        exit 1
    fi

    # 选择jar逻辑, 正常已经不会出现如果出现需要看是否是代码错误
    local i
    local jar_path_index
    local jar_path=${jar_path_list[0]}
    if (( $jar_num > 1 )); then

        echo "存在多个jar? 是否选择一个jar, 查看是否mvn脚本逻辑错误, 如果需要中断输入 CTRL + C"

        while [ -z `grep -E '^[0-9][0-9]*$' <<< "$jar_path_index"` ] || [ $jar_path_index -lt 0 ] || [ $jar_path_index -gt ${#jar_path_list[@]} ]; do
            for(( i=0; i<${#jar_path_list[@]}; i++)) do
                if [ -z "$jar_path_index" ] || [ ! -z `grep -E '^[0-9][0-9]*$' <<< "$jar_path_index"`  ] || [ ! -z `grep "${jar_path_index}" <<< "${jar_path_list[i]}"` ]; then
                    echo "$i) ${jar_path_list[i]}"
                fi
            done
            read -p "选择运行的jar : " jar_path_index
        done
        jar_path=${jar_path_list[$jar_path_index]}
        echo "输入 [$jar_path_index] , 选择 [$jar_path]"

    fi


    if [[ -z $class_file_path ]]; then
        echo "java ${default_map['remote_debug']} -jar $jar_path"
        java ${default_map['remote_debug']} -jar $jar_path
    else
        echo "java ${default_map['remote_debug']} -cp $jar_path $class_file_path"
        java ${default_map['remote_debug']} -cp $jar_path $class_file_path
    fi


}


# 运行maven项目,只是编译不打包,开启远程debug,远程端口5005
# :filter_class:$1: 运行的class过滤字符串
function run() {
    local filter_class=$1
    select_class "src/main" $filter_class
    local main_class_path=$select_class_result
    if [[ -z $main_class_path ]]; then
        echo "未选择 main java 无法运行"
        return 1
    fi

    local module_name_path=${main_class_path%/*}
    if [[ "$module_name_path" == "$main_class_path" ]]; then
        mvn exec:exec -Dexec.executable="java" -Dexec.args="-classpath %classpath ${default_map['remote_debug']} ${main_class_path}"
        return 0
    fi
    # 如果模块名不为空, 即main_class_path中有 '/' 需要重新处理 main_class_path
    main_class_path=${main_class_path##*/}
    local class_path_list=($(find ./ -name "classes" | grep "/target/classes"))

    # 当前目录
    local current_path=$(pwd)

    # maven 自身jar
    local class_path=""
    local i
    for(( i=0; i<${#class_path_list[@]}; i++)) do
        local class_path_item=${class_path_list[i]}
        
        # 将 ./ 替换成真实目录否则正常使用
        if [[ "$class_path_item" == \.* ]]; then
            class_path_item=${class_path_item/./$current_path}
        fi

        class_path="${class_path_item}:${class_path}"
    done


    # 解析依赖的jar路径
    local jar_path=""
    local jar_path_list=($(mvn dependency:build-classpath | grep -v "Download" | grep -v "INFO" | grep -v "WARNING" | grep -v "ERROR" | grep "jar"))
    for(( i=0; i<${#jar_path_list[@]}; i++)) do
        local jar_path_item=${jar_path_list[i]}
        jar_path="${jar_path_item}:${jar_path}"
    done

    mvn exec:exec -pl ${module_name_path} -Dexec.executable="java" -Dexec.args="-classpath ${class_path}${jar_path}%classpath ${default_map['remote_debug']} ${main_class_path}"
 
 
}

# 初始化普通maven项目
function init_maven_jar() {
    # maven groupId
    local groupId
    # maven artifactId
    local artifactId

    read -p "请输入groupId,如果输入空则默认使用 [${default_map['init_maven_group_id']}]  :" groupId
    test -z "$groupId" && groupId="${default_map['init_maven_group_id']}"

    read -p "请输入artifactId : " artifactId
    while [ -z $artifactId ]; do
        read -p "不允许输入空请重新输入, artifactId : " artifactId
    done

    # 初始化普通maven项目, 使用模板maven-archetype-quickstart
    mvn archetype:generate -DgroupId=$groupId -DartifactId=$artifactId -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
}

# 初始化maven项目
# :INIT_ACTION:$1: 需要初始化的maven项目类型, 现在只是支持jar
function init_maven() {
    local INIT_ACTION=$1
    shift 1
    case $INIT_ACTION in
        'jar' )
            # 初始化普通maven项目
            init_maven_jar "$@"
            ;;
    esac
}

case $ACTION in
    '--help' )
        help
        ;;
    'deploy' )
        deploy "$@"
        ;;
    'run' )
        run "$@"
        ;;
    'debug' )
        default_map['remote_debug_suspend']='y'
        default_map_init
        run "$@"
        ;;
    'find_main' )
        find_main_class "$@"
        ;;
    'init' )
        # 初始化maven项目
        init_maven "$@"
        ;;
    * )
        echo "未知操作"
        help
        ;;
esac
