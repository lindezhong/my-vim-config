# 查看mvn.sh脚本帮助文档
mvn.sh --help
# 扫描本目录下所有的main java
mvn.sh find_main {过滤字符1} {过滤字符2}
# 部署maven项目,运行前强制打包编译
mvn.sh deploy "{cmd:mvn.sh find_main src/main}"
# 运行maven项目,只是编译不打包,开启远程debug,远程端口5005,不阻塞启动
mvn.sh run "{cmd:mvn.sh find_main src/main}"
# 运行maven项目,只是编译不打包,开启远程debug,远程端口5005,阻塞启动
mvn.sh debug "{cmd:mvn.sh find_main src/main}"
# 初始化模板项目, 读取以 mvn_ 开头的模板项目
mvn.sh init "{cmd:template.sh list | grep ^mvn_ | sed 's/mvn_//g'}"
