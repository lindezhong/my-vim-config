# 中文输入法

先在设置中寻找输入法(keyboard)设置,寻找到中文智能输入法(Intelligent Pinyin),如果不存在则执行以下操作

```shell
# 1. 安装中文字库及中文语言包:
sudo apt install fonts-noto-cjk
sudo apt install language-pack-zh-hans language-pack-zh-hans-base
# 2. 设置操作系统语言为UTF-8，该设置将在终端重启后生效
echo "LANG=zh_CN.UTF-8" >> ~/.bashrc
# 3. 重新设置语言为utf-8让其生成步骤1生成的语言
sudo dpkg-reconfigure locales
# 4. 再次查看输入法(keyboard)中是否存在中文智能输入法(Intelligent Pinyin), 如果不存在安装它
# 安装后查看是否存在中文智能输入法, 如果不存在重启电脑
sudo apt install ibus ibus-libpinyin
```

# 火狐全屏时黑一下晃眼睛问题解决办法
地址栏输入 about:config，回车进入配置页面。分别搜索下面三项，功能看注释
1. full-screen-api.warning.timeout 双击设置为 0 //关闭视频进入全屏时的提示
2. full-screen-api.transition-duration.enter 双击设置为 ‘0 0’ // 去除全屏模式的过渡动画–进入
3. full-screen-api.transition-duration.leave 双击设置为 ‘0 0’ // 去除全屏模式的过渡动画–退出

# 火狐浏览器触摸兼容
1. 在火狐浏览器地址栏输入 about:config 回车设置 dom.w3c_touch_events.enabled项改为1（启用），默认为2（自动）
2. 修改文件 /etc/security/pam_env.conf 在文件最后添加 MOZ_USE_XINPUT2 DEFAULT=1
3. 如果鼠标滚轮滚送速度慢在火狐浏览器地址栏输入 about:config 回车设置三个配置
    - mousewheel.min_line_scroll_amount项为40
    - general.smoothScroll项为true
    - general.smoothScroll.pages项为false
4. 重启系统

# 修改ubuntu合盖动作
修改文件: sudo vim /etc/systemd/logind.conf
- HandleLidSwitch=poweroff #关闭盖子时关闭电源。
- HandleLidSwitch=hibernate #关闭lid时需要休眠（需要测试hibernate是否工作
- HandleLidSwitch=ignore  #什么都不做。
- HandleLidSwitch=suspend #(默认值)当盖子关闭时暂停笔记本电脑 -- 耗电。

重启或执行 sudo systemctl restart systemd-logind.service 生效

# ubuntu侧边栏自动隐藏
- dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
- dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide false
- dconf write /org/gnome/shell/extensions/dash-to-dock/autohide true

# ubuntu屏幕不自动旋转
gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true

# 关闭软件更新器开机提醒弹窗
打开终端(Ctrl+Alt+T )，并运行以下命令在Ubuntu系统上禁用Update Manager自动通知：
gconftool -s --type bool /apps/update-notifier/auto_launch false

要重新启用Update Manager自动通知，请运行以下命令：
gconftool -s --type bool /apps/update-notifier/auto_launch true

# 禁用切换上、下工作区快捷键
gsettings set "org.gnome.desktop.wm.keybindings" switch-to-workspace-left "['']"
gsettings set "org.gnome.desktop.wm.keybindings" switch-to-workspace-right "['']"
gsettings set "org.gnome.desktop.wm.keybindings" move-to-workspace-right "['']"
gsettings set "org.gnome.desktop.wm.keybindings" move-to-workspace-left "['']"

# 使用命令行连接wifi

## 使用nmcli(更具体的可以看bash/bash_completion_tips/nmcli)
1. 列出可用wifi网络，包括隐藏的网络
nmcli dev wifi list
2. 连接wifi, 如果是隐藏wifi需要添加参数`hidden yes`(非隐藏wif无需添加)
nmcli dev wifi connect <SSID> password <password> hidden yes
3. 查看连接名：
nmcli connection show
4. 激活连接
nmcli connection up <connection-name>
5. 删除配置, 系统将忘记该SSID相关联的网络
nmcli connection delete <connection-name>
请注意，删除连接配置不会立即中断当前的网络连接。你可能需要重新启动网络服务或断开并重新连接WiFi来应用更改：
sudo service network-manager restart
或者你可以通过以下命令断开并重新连接WiFi：
nmcli connection down <connection-name>
nmcli connection up <connection-name>


## 使用 wpasupplicant

1. 安装wpasupplicant
sudo apt install wpasupplicant
2. 将wifi的账号(essid) 和 密码输入文件
wpa_passphrase essid password | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf
3. 重启wifi 
wpa_cli -i wlan0 reconfigure
4. 完整配置如下, 支持多个wifi秘密 priority为优先级，值越大，优先级越高。
```config
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid="Honor 10"
    psk="zyj123#.."
    priority=5
} 
network={
    ssid="company"
    psk="companyPwd"
    priority=4
}
```

# 在linux下烧录iso文件

## 烧录windows的iso文件

可以通过WoeUSB烧录Windows的iso文件 [WoeUSB github 页面](https://github.com/WoeUSB/WoeUSB)

WoeUSB 可以通过存命令行无需依赖图形化界面的烧录工具

1. 下载[WoeUSB](https://github.com/WoeUSB/WoeUSB/releases/)对应的命令行版本, 格式如下`woeusb-${version}.bash`
2. 添加`woeusb-${version}.bash`的可执行权限执行`chmod +x woeusb-${version}.bash`
3. 添加woeusb需要的相关依赖, 依赖页可查看 [WoeUSB相关依赖](https://github.com/WoeUSB/WoeUSB/wiki/Dependencies) , 或者在WoeUSB的github页面查看
4. 插入u盘并且执行`sudo fdisk -l`查看u盘盘符一般为`/dev/sd` 开头比如 `/dev/sda` `/dev/sdb` 等
5. 执行 `sudo ./woeusb-5.2.4.bash --device win10.iso /dev/sda` 烧录windows iso文件到u盘

## 烧录linux的iso文件

1. 可以通过 [BalenaEtcher](https://github.com/balena-io/etcher/releases) 烧录,但高版本可能会报错选择低于v18.12的版本即可
2. 请注意如果下载的是AppImage版本的不能从命令行打开, 只能找到该文件后右击Run
3. 由于AppImage依赖qt在某些版本上缺少依赖启动不了, 这个时候可以命令行运行查看缺少的依赖


