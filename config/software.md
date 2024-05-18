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

