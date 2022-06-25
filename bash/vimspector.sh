#!/bin/bash

ACTION=$1

test -z "$ACTION" && ACTION="--help"

declare -A default_map=()
# vimspector配置文件存放位置(不完整路径),需要填充当前脚本路径才是完整路径
default_map['config_dir']='vimspector-config'
# vimspector配置文件名后缀,配置文件命名规则: 语言-vimspector.json 比如 : c-vimspector.json
default_map['config_file_suffix']="-vimspector.json"
# 将vimspector配置文件复制到那个文件目录(默认当前文件夹下 .vimspector.json 文件)
default_map['config_file_target_path']=".vimspector.json"

defaultMapInit() {

    local script_path=$0
    while [ -L $script_path ]; do
        # 如果是软连接要处理真实路径
        script_path=$(ls -al $script_path)
        script_path=${script_path##*->}
    done
    local home_path=$(readlink -f $(dirname "$script_path"))
    local script_name=$0
    # vimspector配置文件存放位置(完整路径)
    default_map['config_path']="$home_path/${default_map['config_dir']}"
}

defaultMapInit

# 帮助文档
help() {
    echo '
--help : 查看帮助文档
    vimspector.sh --help
    return : 帮助文档信息

language : 查看支持的语言
    vimspector.sh language
    return : 返回支持的语言

config : 复制对应语言的配置到本目录下
    vimspector.sh config [${语言}]
    $2 : 语言,复制 $2-vimspector.json 到本地
    return : 在本地生成 .vimspector.json 文件
    '
}

# 查看支持的语言
language() {
    local vimspector_config_path_list=($(ls ${default_map['config_path']}))
    local vimspector_config=""
    local i
    for(( i=0; i<${#vimspector_config_path_list[@]}; i++)) do
        local vimspector_config_path=${vimspector_config_path_list[i]}
        if (( i > 0 )); then
            vimspector_config="$vimspector_config "
        fi
        local language=${vimspector_config_path%%${default_map['config_file_suffix']}*}
        vimspector_config="$vimspector_config $language"
    done
    echo $vimspector_config
}


# 复制对应语言的配置到本目录下
config() {
    local language=$1
    local language_list=$(language)
    while [[ ! "${language_list[@]}" =~ "${language}" ]] || [ -z "${language}" ]; do
        read -p "只支持语言 [$language_list] : " language
    done

    local vimspector_config_path="${default_map['config_path']}/${language}${default_map['config_file_suffix']}"

    echo "复制文件 $vimspector_config_path 到当前目录 "
    cp $vimspector_config_path ${default_map['config_file_target_path']}
}

case $ACTION in
    --help )
        help
        ;;
    config )
        config "$2"
        ;;
    language )
        language
        ;;
    * )
        echo "未知的操作: $ACTION"
        help
        ;;
esac
