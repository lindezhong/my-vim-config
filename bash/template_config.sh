#!/bin/bash

# 全局的变量可在config_init初始化/修改

# 关键字映射, 在最终的提示中会将 key 替换成 value
# 只是影响到最终的提示, 不影响过程中的转换, 即如果需要嵌套数组还是需要通过 ' " 的变化
# 规则与html的特殊转义符一致
declare -A keywords_mapping=(
    ["&amp;"]="\&"
    ["&nbsp;"]=" "
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
    ["&excl;"]='!'
)


# 反模板化模式开关, 设为 "true" 则将目录反向生成为模板
# 正常模式: 模板(含${var}和实体编码) → 生成目录(变量展开, 实体还原)
# 反模板化: 生成目录(普通文件) → 模板(特殊字符实体编码)
templatize_mode=""

# 反模板化实体编码映射 (与 keywords_mapping 反方向)
# 仅包含 eval 必须转义的字符, 避免过度编码影响可读性
# & 必须最先替换, 迭代时显式跳过并优先处理
declare -A templatize_keywords_mapping=(
    ["&"]='\&amp;'
    ["\\"]='\&bsol;'
    ["\""]='\&quot;'
    ["\`"]='\&grave;'
    ["\$"]='\&dollar;'
    ["!"]='\&excl;'
)


# 忽略路径列表, 可以匹配, ${template_scr_path} 或 ${generate_target_path}
# 如果匹配成功的路径则不做任何事情
# 添加格式为 . 开头 . 开头可以表示 ${template_path} 或 ${generate_path}
ignore_path_list=()

# 只复制路径列表, 可以匹配, ${template_scr_path} 或 ${generate_target_path}
# 如果匹配成功的路径则只是复制
# 添加格式为 . 开头 . 开头可以表示 ${template_path} 或 ${generate_path}
only_copy_path_list=()

# 模板默认方法, 初始化模板时候调用
# 通常来说是如果需要影响到模板需要定义一些全局变量, 有些系统自带的全局变量的作用也只限与这个脚本的方法使用
# 系统的可初始化的变量和作用查看这个脚本的全局变量和这个方法的注释
# :template_path:$1: 模板路径
# :generate_path:$2: 生成目录路径
function config_init() {
    local template_path="$1"
    local generate_path="$2"

    # 添加忽略路径列表
    # ignore_path_list[${#ignore_path_list[@]}]=''
    
    # 添加只复制路径列表
    # only_copy_path_list[${#only_copy_path_list[@]}]=''

}

# 内置的模板方法, 将路径转换为真实路径 , 这个方法是给覆盖的配置脚本调用的
# 如果遇到忽略文件返回空, 如果是只复制文件需要手动复制并且返回空
# :template_scr_path:$1: 待转换的路径, 会将${template_path}替换成'.'以方便做处理, 如果需要原始的路径需要替换回去
# :template_path:$2: 将要生成的文件路径, 可能会传入文件或目录
# :generate_path:$3: 将要生成的文件路径, 可能会传入文件或目录
# :returns:echo: 转换后的路径,无返回则表示忽略改路径, 需要调用方会将 . 转换为generate_path
function internal_convert_real_path() {
    local template_scr_path="$1"
    local template_path="$2"
    local generate_path="$3"
    eval 'local real_path="'$template_scr_path'"'

    local ignore_path
    for ignore_path in "${ignore_path_list[@]}"; do
        if [[ "$ignore_path" == "$template_scr_path" ]] || [[ "$ignore_file" == "$real_path" ]]; then
            echo "忽略生成文件 $template_scr_path ==> $real_path" >&2
            return 0
        fi
    done

    local only_copy_path
    for only_copy_path in "${only_copy_path_list[@]}"; do
        if [[ "$only_copy_path" == "$template_scr_path" ]] || [[ "$only_copy_path" == "$real_path" ]]; then
            # 将 . 还原为原始路径
            echo "只复制文件 $template_scr_path ==> $real_path" >&2
            template_scr_path=${template_scr_path/\./${template_path}}
            real_path=${real_path/\./${generate_path}}
            cp -r "$template_scr_path" "$real_path"
            return 0
        fi
    done
    echo "$real_path"
    
}

# 模板默认方法, 将路径转换为真实路径
# 默认方法直接转发到 internal_convert_real_path 实现
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
    # echo "before $template_src_path ==> $generate_target_path"
    
}

# 生成文件/目录前后的事情
# :template_src_path:$1: 将要生成的文件路径, 可能会传入文件或目录
# :generate_target_path:$2: 将要生成的文件路径, 可能会传入文件或目录
function generate_path_after() {
    local template_src_path="$1"
    local generate_target_path="$2"
    # echo "after  $template_src_path ==> $generate_target_path"
    
}



# 内部的处理文件内容生成可用的文件, 前置处理, 用于防止执行脚本失败
# 默认不做任何处理完全显示
# :file_path:$1: 原始文路径 
# :return:echo: 处理后的文件内容 
function internal_process_file_content_before() {
    local file_path="$1"
    if [[ "$templatize_mode" == "true" ]]; then
        # 实体编码: 按 templatize_keywords_mapping 替换, 编码后不含 eval 特殊字符
        local file_content
        file_content=$(cat "$file_path")
        # & 必须最先替换, 避免后续实体中的 & 被二次编码
        local normaliza_value=${templatize_keywords_mapping["&"]}
        file_content=${file_content//&/${normaliza_value}}
        local keyword=""
        for keyword in ${!templatize_keywords_mapping[@]}; do
            if [[ "$keyword" == "&" ]]; then continue; fi
            normaliza_value=${templatize_keywords_mapping[$keyword]}
            if [[ "$keyword" == '\' ]]; then
                # \ 在 ${//} 模式中是转义符, 需写 \\
                file_content=${file_content//\\/${normaliza_value}}
            else
                file_content=${file_content//${keyword}/${normaliza_value}}
            fi
        done
        echo "$file_content"
    else
        cat "$file_path"
    fi
}

# 内部的处理文件内容生成可用的文件, 后置处理, 用于还原真实内容
# :file_content:$1: 原始文件内容 
# :return:echo: 处理后的文件内容 
function internal_process_file_content_after() {
    local file_content="$1"

    if [[ "$templatize_mode" == "true" ]]; then
        echo "$file_content"
        return
    fi
    # 关键字转义
    if [[ "$file_content" == *"&"* ]]; then
        local keyword=""
        local normaliza_value=""
        for keyword in ${!keywords_mapping[@]}; do
            normaliza_value=${keywords_mapping[$keyword]}
            file_content=${file_content//${keyword}/${normaliza_value}}
        done
    fi
    echo "$file_content"
}

# 处理文件内容生成可用的文件, 前置处理
# :file_path:$1: 原始文路径 
# :return:echo: 处理后的文件内容 
function process_file_content_before() {
    local file_path="$1"
    internal_process_file_content_before "$file_path"
    
}

# 处理文件内容生成可用的文件, 后置处理
# :file_content:$1: 原始文件内容 
# :return:echo: 处理后的文件内容 
function process_file_content_after() {
    local file_content="$1"
    internal_process_file_content_after "$file_content"
    
}
