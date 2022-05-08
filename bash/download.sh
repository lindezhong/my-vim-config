#!/bin/bash

help() {
    echo '
下载多个文件到某个目录
$1 : 文件地址存储路径(该文件的每一行都为一个url)
$2 : 下载到那个目录
return : 在$2路径下生成多个目录
    '
    exit 0
}


download_file_path=$1
download_dir_path=$2


test -z $download_file_path && download_file_path="--help"
if [[ "$download_file_path" == "--help" ]]; then
    help
fi


download_files=$(cat $download_file_path)

mkdir -p $download_dir_path
cd $download_dir_path
for download_path in "${download_files[@]}"; do
    wget $download_path
done


