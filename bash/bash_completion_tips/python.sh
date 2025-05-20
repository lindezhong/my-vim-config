# 查看帮助文档
python.sh --help
# 安装构建/打包的相关依赖
python.sh setuptools env
# 初始化一个可打包python项目
python.sh setuptools init {项目名}
# 将本地python项目安装到site-packages
python.sh setuptools install
# 打包本地python项目,在./dist 生成文件夹
python.sh setuptools build
# 运行单元测试用例, 等价于 python setup.py test
python.sh setuptools test {cmd:comp_file_direct}
