#!/bin/bash
# ubuntu侧边栏自动隐藏
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide false
dconf write /org/gnome/shell/extensions/dash-to-dock/autohide true

# ubuntu屏幕不自动旋转
gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true
