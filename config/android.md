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

# 再来，按照系统版本输入命令，不需要root权限
# Android 12L和Android 13
./adb shell "settings put global settings_enable_monitor_phantom_procs false"

# Android 12，无GMS
./adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"

# Android 12，有GMS
./adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent; /system/bin/device_config put activity_manager max_phantom_processes 2147483647"

# 重开机，Termux在后台运行时应该就不会被杀
```


# termux

## 换源

```shell
# 可通过官方提供了图形界面（TUI）来半自动替换镜像，推荐使用该种方式以规避其他风险
termux-change-repo
```

## ssh

```shell
# 安装OpenSSH
pkg install openssh

# 运行SSH Server
sshd

# 设置密码
passwd 

# 获得Android IP
ifconfig

# 客户端运行
ssh android_ip -p 8022
```

## proot-distro 

```shell
# 安装proot-distro
pkg install proot-distro

# 可以查看可安装的Linux系统。
proot-distro list

# 安装debian
proot-distro install debian

# 登陆debian
proot-distro login debian

```

## 桌面环境安装

```shell
# 安裝TigerVNC。
pkg install x11-repo
pkg install tigervnc

# 安裝XFCE4桌面环境、Firefox浏览器
pkg install xfce4 xfce4-goodies firefox vim

# 用VIM編輯：vim ~/.vnc/xstartup，全部刪除，改加入以下內容:
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADRESS
export PULSE_SERVER=127.0.0.1 && pulseaudio --start --disable-shm=1 --exit-idle-time=-1
exec startxfce4

# 賦予xstartup執行權限
chmod +x ~/.vnc/xstartup

# 用VIM編輯：vim ~/.vnc/config，加入以下內容
geometry=1920x1080
depth=32
localhost=no

# 在本機開啟vnc server，再設定vnc的密碼。
vncserver

# 查看vnc端口
ps -ef | grep vnc

# 開啟AVNC APP，輸入localhost:port，再輸入密碼即可連線。
```

## Termux防止杀后台 解决signal 9错误 

可通过禁止 [安卓 Phantom Process Killing 机制](#安卓-Phantom-Process-Killing-机制) 解决
