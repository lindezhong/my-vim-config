#!/bin/bash

download_file_path=$1
download_dir_path=$2

download_files=$(cat $download_file_path)

mkdir -p $download_dir_path
cd $download_dir_path
for download_path in "${download_files[@]}"; do
    wget $download_path
done
