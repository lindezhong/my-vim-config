# webdav(基于nginx)

```shell
# 可以使用url : http://ip:18081/目录 访问/webdav/目录 的webdav 服务

# 1. 先安装完整版本的nginx
sudo apt install nginx-full

# 2. 配置一个webdav账号密码(通过openssl)
mkdir /etc/webdav/ && echo "用户名:$(openssl passwd -apr1)"  > /etc/webdav/.credentials.list

# 3. 新建 webdav 存放资源文件
mkdir /webdav

# 4. 将以下配置复制到 /etc/nginx/conf.d/webdav.conf 文件上(文件需要新建)
server {
    listen 18081;
    listen [::]:18081;

    server_name localhost;

    # 认证方式
    auth_basic              realm_name;
    # 存放认证用户名、密码文件（确认有对应权限）
    auth_basic_user_file    /etc/webdav/.credentials.list;
    location / {
        # webdav服务访问的根目录
        root /webdav;

        # dav allowed method
        dav_methods     PUT DELETE MKCOL COPY MOVE;
        # Allow current scope perform specified DAV method
        dav_ext_methods PROPFIND OPTIONS;

        # In this folder, newly created folder or file is to have specified permission. If none is given, default is user:rw. If all or group permission is specified, user could be skipped
        dav_access      user:rw group:rw all:r;
    }
    # Temporary folder
    client_body_temp_path   /tmp/webdav;

    # MAX size of uploaded file, 0 mean unlimited
    client_max_body_size    0;

    # Allow autocreate folder here if necessary
    create_full_put_path    on;
}

# 5. 重启nginx
sudo systemctl restart nginx

# 6. 如果出现上传webdav文件失败情况检查是否是因为权限问题
# 比如nginx日志(/var/log/nginx/error.log)中出现Permission denied
# 解决方案给nginx worker 进程对应的用户www-data(使用 ps -ef | grep nginx 查询)授予权限
chown -R www-data /webdav
```

# 源码安装vim

```shell
# 1. clone vim 源码
git clone https://github.com/vim/vim

# 2. 查询vim版本(tags)
git tag

# 3. 切换到某个版本(tags)
git checkout {tag}

# 4. 创建vim目录
sudo mkdir -p /opt/vim

# 5. 配置编译参数
#!/bin/bash
# 配置 Vim 的编译选项（需在源码目录的 src 文件夹内执行）
# ./configure \
# --prefix=/opt/vim \  # 将 Vim 安装到用户目录，避免需要 root 权限
# --with-features=huge \              # 启用最大功能集（支持代码折叠/多缓冲等高级功能）
# --enable-gui=gtk2 \                 # 编译 GTK2 图形界面（需安装 libgtk2.0-dev）
# --enable-gui=gtk3 \                 # 使用 GTK3 图形界面（需安装 libgtk-3-dev）
# --enable-fontset \                  # 支持多字体混合显示（如中英文不同字体）
# --enable-cscope \                   # 集成 Cscope 代码分析工具
# --enable-multibyte \                # 支持多字节字符（中文/日文等）
# --enable-python3interp \            # 嵌入 Python3 解释器（需 python3-dev 库）
# --with-python3-config-dir=$(python3-config --configdir) \  # 自动获取 Python3 库配置路径
# --enable-rubyinterp \               # 嵌入 Ruby 解释器（需 ruby-dev 库）
# --enable-luainterp \                # 嵌入 Lua 5.1 解释器（需 liblua5.1-dev）
# --enable-perlinterp \               # 嵌入 Perl 解释器（需 libperl-dev 库）
# --with-x                            # 启用 X11 图形系统支持(需 libxt-dev 库)

./configure \
    --prefix=/opt/vim \
    --with-features=huge \
    --enable-gui=auto \
    --enable-fontset \
    --enable-cscope \
    --enable-multibyte \
    --enable-python3interp \
    --with-python3-config-dir=$(python3-config --configdir) \
    --enable-rubyinterp \
    --enable-luainterp \
    --enable-perlinterp \
    --with-x 

# 6 错误解决
# ./configure 执行错误如果需要重试可以先执行 `make distclean` 清理旧的配置缓存

# 6.1 如果报如下错误 
#       checking for tgetent()... configure: error: NOT FOUND!
#       You need to install a terminal library; for example ncurses.
#       On Linux that would be the libncurses-dev package.
#       Or specify the name of the library with --with-tlib.
sudo apt install libncurses-dev

# 6.2 configure: error: could not configure X
sudo apt install libxt-dev

# 7. 编译
make && sudo make install

# 8. 使用update-alternatives切换vim版本
sudo update-alternatives --install /usr/local/bin/vim vim /opt/vim/bin/vim 100
sudo update-alternatives --set vim /opt/vim/bin/vim

```
