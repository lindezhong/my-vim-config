# 使用wifi连接adb

1. 打开开发者选项

2. 在adb选项中打开无线调试模式(可以看到ip地址和端口ip1:port1)

3. 打开使用配对码配对设备(会出现配对码code2和ip地址和端口ip2:port2)

4. 连接机器

```shel
# [IP位址]      [通訊埠]
adb pair ip2:port2
# 輸入配对码code2

# 连接机器
adb connect ip1:port1

# 查看连接到的adb
adb devices
# 出现 : ip1:port1 device

# adb退出
exit
```
# 安卓-Phantom-Process-Killing-机制

Phantom Process Killing : Android 12以上的设备只要Termux进后台，运行桌面环境这类占用高CPU的程序，便有可能被Android系统杀死。此时Termux会抛出一个"Process completed (signal 9) - press Enter"信息。

出处: https://github.com/agnostic-apollo/Android-Docs/blob/master/en/docs/apps/processes/phantom-cached-and-empty-processes.md

禁止Phantom Process Killing 机制

```shell
# 使用adb连接到安卓

# Android 12L和Android 13

# 再来，按照系统版本输入命令，不需要root权限
# Android 12L和Android 13
adb shell "settings put global settings_enable_monitor_phantom_procs false"

# Android 12，无GMS
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"

# Android 12，有GMS
adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent; /system/bin/device_config put activity_manager max_phantom_processes 2147483647"

# Android 16
adb shell device_config set_sync_disabled_for_tests persistent
adb shell device_config put activity_manager max_phantom_processes 65536
# 验证是否生效, 应该返回 65536
adb shell device_config get activity_manager max_phantom_processes

# 重开机，Termux在后台运行时应该就不会被杀
```


# termux

## 换源

```shell
# 可通过官方提供了图形界面（TUI）来半自动替换镜像，推荐使用该种方式以规避其他风险
termux-change-repo
```

## 访问手机存储空间

```shell
# 需要在手机上执行, 不能通过远程ssh执行
termux-setup-storage
```

## proot-distro 

```shell
# 安装proot-distro
pkg install proot-distro

# 可以查看已经安装的Linux系统。
proot-distro list

# 安装debian
# proot-distro 新版本(5.0后)已经支持使用docker镜像安装
# 所以需要安装那些可以去docker hub上获取
proot-distro install debian

# 登陆debian
proot-distro login debian

```

## 安装termux-x11(proot-distro)

termux-x11: A Termux add-on app providing Android frontend for Xwayland.

### termux中安装依赖

```shell
# 在termux中安装x11依赖
pkg install x11-repo
pkg install termux-x11-nightly

# 这个步骤无需执行如果有问题再执行
# 在https://github.com/termux/termux-x11/releases/tag/nightly下载
# termux-x11-nightly-xxxx-all.deb
# dpkg -i termux-x11-xxxx-all.deb

# 允许外部应用调用 termux
# 让debian支持x11
echo 'allow-external-apps=true' >> ~/.termux/termux.properties

# proot-distro 中视频和声音可以显示的依赖
# 安装 Virglrenderer 依赖以支持 GPU 3D 加速 
pkg install virglrenderer-android
# 安装 Pulseaudio 依赖以支持音频
pkg install pulseaudio

# proot-distro 安装 debian
pkg install proot-distro
proot-distro install debian
# 登录debian继续
proot-distro login debian
```


### 在debian中继续安装依赖

```shell
# 先更新源
apt update

# 安装桌面环境
apt install xfce4

# 如果需要使用 ssh -X 的方式连接则不能直接ssh到termux需要ssh到proot-distro debian
# 因为这样才能使用单独的转发能力, 所以需要单独的安装ssh服务端
# 这样可以使用  ssh -X root@android_ip -p 8122 启动X11转发
apt install openssh-server
# 开启远程连接和X11转发
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i -E 's/^#?Port .*/Port 8122/'                  /etc/ssh/sshd_config
sed -i -E 's/^#?X11Forwarding.*/X11Forwarding yes/'  /etc/ssh/sshd_config
sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 生成.Xauthority文件让登录正常
touch ~/.Xauthority

# 设置root用户密码
passwd
```

### 在debian配置xfce启动脚本

将以下内容配置到`x11`
并且执行`chmod +x x11`


```shell
# 同时启用 sshd, 让  ssh -X root@android_ip -p 8122 支持 X11 转发
/usr/sbin/sshd
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1 &
env DISPLAY=:1 dbus-launch --exit-with-session xfce4-session

```

### 安装termux-x11

在https://github.com/termux/termux-x11/releases/tag/nightly下载的app-universal-debug.apk安装

### 启动方式

1. 在debian执行`./x11`(配置xfce启动脚本中生成的脚本, 需要执行两次不知道为啥)
2. 打开termux-x11查看桌面



## 安装termux-x11(原生安装在原始termux中)

### termux中安装依赖

termux-x11: A Termux add-on app providing Android frontend for Xwayland.

```shell
# 在termux中安装依赖
# 使用xfce作为桌面环境
pkg install x11-repo
pkg install termux-x11-nightly
pkg install xfce
# termux-x11基于xwayland所以需要依赖安装
pkg install xwayland

# 这个步骤无需执行如果有问题再执行
# 在https://github.com/termux/termux-x11/releases/tag/nightly下载
# termux-x11-nightly-xxxx-all.deb
# dpkg -i termux-x11-xxxx-all.deb
```

### 配置ssh x11支持

修改文件`$PREFIX/etc/ssh/sshd_config` 开启以下配置
```config
X11Forwarding yes	    # 允许X11转发
X11DisplayOffset 10   #（可选）转发从localhost:10开始
X11UseLocalhost no	#（可选）禁止将X11转发请求绑定到本地回环地址上
AddressFamily inet	#（可选）强制使用IPv4通道。
```


### 配置xfce启动脚本

将以下内容配置到`x11`
并且执行`chmod +x x11`

```shell
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1 &
env DISPLAY=:1 dbus-launch --exit-with-session xfce4-session
```

### 安装termux-x11

在https://github.com/termux/termux-x11/releases/tag/nightly下载的app-universal-debug.apk安装

### 启动方式

1. 在termux执行`./x11`(配置xfce启动脚本中生成的脚本, 需要执行两次不知道为啥)
2. 打开termux-x11查看桌面


## ssh

```shell
# 安装OpenSSL
pkg install openssl

# 安装OpenSSH
pkg install openssh

# 生成ssh key
ssh-keygen -A

# 运行SSH Server
sshd

# 设置密码
passwd 

# 获得Android IP
ifconfig

# 客户端运行
ssh android_ip -p 8022
```

## Termux防止杀后台 解决signal 9错误 

可通过禁止 [安卓 Phantom Process Killing 机制](#安卓-Phantom-Process-Killing-机制) 解决
