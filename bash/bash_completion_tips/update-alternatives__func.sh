#!/bin/bash

# 提示所有的软链接, 以目录提示的格式提示出去 
function get_link_path() {
    local path="$1"
    local link_path_list=($(update-alternatives  --get-selections | awk '{print $1}' | xargs -I {} update-alternatives --query {} | grep Link | awk '{print $2}' | grep "^$path"))

    local link_path
    for link_path in "${link_path_list[@]}"; do
        local separator=""
        link_path=${link_path/${path}/}
        if [[ "$link_path" == /* ]]; then
            separator="/"
            link_path=${link_path/\//}
        fi
        link_path=${link_path%%/*}
        echo "${path}${separator}${link_path}"
    done

    if (( ${#link_path[@]}==0 )); then
       # 如果已有的软链接都不符合情况则提示目录 
       echo '{cmd:_comp_file_direct_}'
    else
        echo "{-filenames}"
    fi
}

# 获取所有的 <name>
function get_all_name() {
    update-alternatives  --get-selections | awk '{print $1}'
}

function get_link_by_name() {
    local name="$1"
    update-alternatives --list ${name}
}

