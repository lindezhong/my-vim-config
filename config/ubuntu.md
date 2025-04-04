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

# 在linux下烧录windows的iso文件

可以通过WoeUSB烧录 [WoeUSB github 嗲之](https://github.com/WoeUSB/WoeUSB)

WoeUSB 可以通过存命令行无需依赖图形化界面的烧录工具

1. 下载[WoeUSB](https://github.com/WoeUSB/WoeUSB/releases/)对应的命令行版本, 格式如下woeusb-${version}.bash
2. 添加woeusb-${version}.bash的可执行权限执行`chmod +x woeusb-${version}.bash`
3. 添加woeusb需要的相关依赖, 依赖页可查看 [WoeUSB相关依赖](https://github.com/WoeUSB/WoeUSB/wiki/Dependencies) , 或者在WoeUSB的github页面查看
4. 插入u盘并且执行`sudo fdisk -l`查看u盘盘符一般为`/dev/sd` 开头比如 `/dev/sda` `/dev/sdb` 等
5. 执行 `sudo ./woeusb-5.2.4.bash --device win10.iso /dev/sda` 烧录windows iso文件到u盘

