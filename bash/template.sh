#!/bin/bash

ACTION="$1"
shift 1

script_path=$0
while [ -L $script_path ]; do
    # 如果是软连接要处理真实路径
    script_path=$(ls -al $script_path)
    script_path=${script_path##*->}
done
home_path=$(readlink -f $(dirname "$script_path"))

# 默认的配置脚本
default_config_shell_path="$home_path/template_config.sh"

# 内置的模板路径, 这个路径下的每个目录都是一个模板
# 内置的模板必须在自身目录下有配置脚本
internal_template_base_path="${home_path}/template"

# 关键字映射, 在最终的提示中会将 key 替换成 value
# 只是影响到最终的提示, 不影响过程中的转换, 即如果需要嵌套数组还是需要通过 ' " 的变化
# 规则与html的特殊转义符一致
declare -A keywords_mapping=(
    ["&nbsp;"]=" "
    ["&amp;"]="&"
    ["&apos;"]="'"
    ["&quot;"]='"'
    ["&vert;"]="|"
    ["&lt;"]="<"
    ["&gt;"]=">"
    ["&equals;"]="="
    ["&semi;"]=";"
    ["&lpar;"]="("
    ["&rpar;"]=")"
    ["&colon;"]=":"
    ["&sol;"]="/"
    ["&bsol;"]='\'
    ["&grave;"]='`'
    ["&dollar;"]='$'
    ["&excl;"]=''
)



# 帮助文档
help() {
    echo '


    '
}

# 通过模板生成一个目录
# :template_path:$1: 模板路径
# :generate_path:$2: 生成目录路径
# :config_shell_path:$3: 配置脚本路径, 用于覆盖 ${default_config_shell_path} 脚本中的方法
#                        config_shell_path为 ($3 , ${template_path}/config.sh , ${default_config_shell_path}) 第一个不为空的值
#                        可以覆盖的方法请查看 ${default_config_shell_path} 脚本
function template_generate_dir() {
    local template_path="$1"
    local generate_path="$2"
    local config_shell_path="$3"
    # 假如 ${config_shell_path} 是在 ${template_path} 路径下则需要忽略配置文件
    # 这个变量就是获取该路径的
    local ignore_generate_config_path=""

    if [[ -z $template_path ]] || ( [ ! -d $template_path ] && [ ! -f $template_path ] ); then
        echo "需要指定模板路径, 请查看帮助文档"
        help
        return 1
    fi


    while [ -z $generate_path ]; do
        read -p "生成路径为空,请输入 : " generate_path
    done

    # 标准输入的路径, 主要是将两个路径的后缀 / 去掉
    if [[ "$template_path" == */ ]]; then
        template_path=${template_path%/*}
    fi
    if [[ "$generate_path" == */ ]]; then
        generate_path=${generate_path%/*}
    fi

    if [[ -z $config_shell_path ]]; then
        config_shell_path="${template_path}/config.sh"
    fi

    if [ ! -f "${config_shell_path}" ]; then
        config_shell_path="$default_config_shell_path"
    fi

    # 如果配置脚本在模板路径下需要忽略配置文件
    if [[ "$config_shell_path" == "$template_path"/* ]]; then
        ignore_generate_config_path=${config_shell_path/${template_path}/.}
    fi

    #  加载 config_shell 脚本, 执行初始化脚本
    #  先加载默认脚本让方法都存在, 再加载其它定义的脚本覆盖默认脚本
    source $default_config_shell_path
    source $config_shell_path
    config_init

    if [ -f "$template_path" ]; then
        # 如果模板是一个文件路径直接生成对应的文件
        generate_path_before "$template_path" "$template_path"
        eval "echo \"$(cat "$template_path")\" > \"$generate_path\""
        generate_path_after "$template_path" "$template_path"
        return 0
    fi

    # 2. 开始生成目录
    generate_path_before "$template_path" "$generate_path"
    mkdir -p $generate_path
    generate_path_after "$template_path" "$generate_path"
    local process_path_list=("$template_path")
    while (( ${#process_path_list[@]} > 0 )); do
        local process_path=${process_path_list[${#process_path_list[@]}-1]}
        unset process_path_list[${#process_path_list[@]}-1]
        
        local sub_dir=""
        # 将子目录添加到处理路径中
        while read sub_dir
        do
            process_path_list[${#process_path_list[@]}]="${sub_dir}"
            local generate_dir_path=${sub_dir/${template_path}/${generate_path}}
            generate_path_before "$sub_dir" "$generate_dir_path"
            mkdir -p "$generate_dir_path"
            generate_path_after "$sub_dir" "$generate_dir_path"
        done  < <(find "$process_path" -maxdepth 1 -mindepth 1 -type d)

        local sub_file=""
        # 处理文件, 自定义描述符3 , 防止在eval中使用到read导致描述符被占用
        exec 3< <(find "$process_path" -maxdepth 1 -mindepth 1 -type f)
        while read -u3 sub_file
        do
            # 将 ${template_path} -> . 这样在转换路径的时候会跟方便
            sub_file=${sub_file/${template_path}/.}
            if [[ "$sub_file" == "$ignore_generate_config_path" ]]; then
                # 如果为忽略文件直接跳过不处理
                continue
            fi
            sub_file=''$(convert_real_path "$sub_file")''
            # 还原 ${template_path} 路径
            local generate_file_path=${sub_file/\./${generate_path}}
            sub_file=${sub_file/\./${template_path}}
            generate_path_before "$sub_file" "$generate_file_path"
            # eval "echo \"$(cat "$sub_file")\" > \"$generate_file_path\""
            eval "local generate_file_content=\"$(cat "$sub_file")\""
            
            # 关键字转义
            if [[ "$generate_file_content" == *"&"* ]]; then
                local keyword=""
                local normaliza_value=""
                for keyword in ${!keywords_mapping[@]}; do
                    normaliza_value=${keywords_mapping[$keyword]}
                    generate_file_content=${generate_file_content//${keyword}/${normaliza_value}}
                done
            fi
        
            echo "$generate_file_content" > "$generate_file_path"
            # 复制原始文件的权限到生成路径
            chmod "--reference=$sub_file" "$generate_file_path"
            generate_path_after "$sub_file" "$generate_file_path"
        done
        exec 3<&-
    done

}

# 本质上只是转发template_generate_dir方法, 但无需配置脚本, 因为内部的模板的配置脚本应该由内部模板自身提供
# :template_name:$1: 模板名, 拼接 ${internal_template_base_path} 生成模板路径 
# :generate_path:$2: 生成目录路径
function internal_template_generate_dir() {
    local template_name="$1"
    local generate_path="$2"
    template_generate_dir "${internal_template_base_path}/${template_name}" "$generate_path"
}

# 获取内部模板名列表
# :return:echo: 内部模板名列表, 用换行分割 
function internal_template_list() {
    
    local template_dir
    while read template_dir
    do
        echo ${template_dir/${internal_template_base_path}\//}
    done  < <(find "$internal_template_base_path" -maxdepth 1 -mindepth 1 -type d)
}

case "$ACTION" in
    --help)
        # 显示帮助文档
        help "$@"
        ;;
    template)
        template_generate_dir "$@"
        ;;
    internal)
        internal_template_generate_dir "$@"
        ;;
    list)
        internal_template_list "$@"
        ;;
    * )
        echo "未知操作 ${ACTION},请查看帮助文档"
        help "$@"
        ;;
esac

