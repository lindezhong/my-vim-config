# 本地启动swagger

1. 初始化脚本

```shell
# 创建目录
sudo mkdir /swagger && cd /swagger 

# 给当前用户授权
sudo chown -R ldz /swagger


# 初始化 npm 项目（一路回车即可）
npm init -y

# 安装 Swagger UI
npm install swagger-ui-dist --save-dev
```

2. 复制以下内容到index.html

```html
<!DOCTYPE html>
<html>
<head>
  <title>My API Docs</title>
  <link rel="stylesheet" type="text/css" href="./node_modules/swagger-ui-dist/swagger-ui.css" />
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="./node_modules/swagger-ui-dist/swagger-ui-bundle.js"></script>
  <script src="./node_modules/swagger-ui-dist/swagger-ui-standalone-preset.js"></script>
  <script>
    window.onload = function() {
      window.ui = SwaggerUIBundle({
        url: "./openapi.yaml",   // ← 指向你的 OpenAPI 文件
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
        ],
        plugins: [
          SwaggerUIBundle.plugins.DownloadUrl
        ],
        layout: "StandaloneLayout"
      });
    };
  </script>
</body>
</html>

```

3. 复制你的openapi.yaml到当前目录

# 通过npx启动


1. 通过命令  npx http-server -c-1 启动

2. 访问 localhost:8080 访问

# 通过nginx来启动

允许将请求到本地的请求通过 headers.curl 文件复制cookie

这样就能在swagger中发起请求了(server必须是 `/` 表示当前地址)

## 安装nginx依赖

```shell
sudo apt-get update && sudo apt-get install -y nginx libnginx-mod-http-lua
```

## 给nginx授权目录权限

比如nginx日志(/var/log/nginx/error.log)中出现Permission denied
解决方案给nginx worker 进程对应的用户www-data(使用 ps -ef | grep nginx 查询)授予权限
sudo setfacl -R -d -m u:www-data:rwx /swagger/


## 配置lua脚本

复制以下内容到 `inject_headers.lua`

需要修改`/swagger/headers.curl`为实际地址

headers.curl 获取方式
1. 浏览器打开需要反代的网站（确保已登录）
2. F12 → Network 面板
3. 刷新页面（F5）
4. 右键列表中任意一个请求 → Copy → Copy as cURL (bash)
5. 整段粘贴覆盖 headers.txt 文件内容


```lua
local headers_file = "/swagger/headers.curl"

local f = io.open(headers_file, "r")
if not f then
    ngx.log(ngx.ERR, "inject_headers: cannot open file")
    return
end
local full = f:read("*a")
f:close()

-- 去掉反斜杠续行
full = full:gsub("\\\r?\n%s*", " ")

-- 提取 cookie
local cookie = full:match("%-b%s+'([^']+)'") or full:match('%-b%s+"([^"]+)"')

-- 提取所有 -H headers
local headers = {}
for block in full:gmatch("%-H%s+'([^']+)'") do
    local name, value = block:match("^([^:]+):%s*(.+)$")
    if name then
        headers[name:lower()] = {name = name, value = value}
    end
end
for block in full:gmatch('%-H%s+"([^"]+)"') do
    local name, value = block:match("^([^:]+):%s*(.+)$")
    if name then
        headers[name:lower()] = {name = name, value = value}
    end
end

-- 注入 Cookie
if cookie then
    ngx.req.set_header("Cookie", cookie)
end

-- 注入其他 headers
for _, h in pairs(headers) do
    ngx.req.set_header(h.name, h.value)
end
```

## 配置swagger-proxy.conf

将以下内容复制到 `/etc/nginx/sites-enabled/swagger-proxy.conf`

需要替换 `/swagger` 为你的实际目录

需要实际配置转发的http, 这里使用

/api/ -> https://example.com/api 

如果需要新的前缀转发需要手动添加

```conf
server {
    listen 8080;
    server_name _;

    root /swagger;
    index index.htm index.html;
    charset utf-8;

    etag off;
    if_modified_since off;
    add_header Cache-Control "no-cache, no-store, must-revalidate" always;
    add_header Pragma "no-cache" always;
    add_header Expires "0" always;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.ya?ml$ {
        default_type text/yaml;
        charset utf-8;
    }

    location /api/ {
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header Access-Control-Allow-Headers * always;

        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS';
            add_header Access-Control-Allow-Headers *;
            add_header Content-Length 0;
            return 204;
        }

        access_by_lua_block {
            local ok, err = pcall(dofile, "/swagger/inject_headers.lua")
            if not ok then ngx.log(ngx.ERR, "lua err: " .. tostring(err)) end
        }

        proxy_pass https://example.com/api/;
        proxy_http_version 1.1;
        proxy_set_header Host hrworkbench.hemaos.com;
        proxy_set_header Connection "";
        proxy_set_header X-Real-IP "";
        proxy_set_header X-Forwarded-For "";
        proxy_set_header X-Forwarded-Proto "";
        proxy_ssl_server_name on;
        proxy_ssl_protocols TLSv1.2 TLSv1.3;
        proxy_pass_header Set-Cookie;
    }


}
```

## 启动脚本

`sudo nginx`

访问 `localhost:8080/index.htm`

