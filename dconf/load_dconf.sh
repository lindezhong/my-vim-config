#!/bin/bash


home_path=$(readlink -f $(dirname "$0"))
tmp_path="$home_path/tmp"
time=$(date "+%Y%m%d-%H%M%S")

dconf_name=$1
dconf_path=$2
dconf_file=$3

# 备份老数据
if [ ! -d $tmp_path ]; then
    mkdir $tmp_path
fi
dconf dump $dconf_path > ${tmp_path}/${dconf_name}-${time}.dconf

# 清除老配置
dconf reset -f $dconf_path

# 加载新配置
dconf load $dconf_path < $dconf_file


