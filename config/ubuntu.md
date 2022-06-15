# 火狐全屏时黑一下晃眼睛问题解决办法
地址栏输入 about:config，回车进入配置页面。分别搜索下面三项，功能看注释
（1）full-screen-api.warning.timeout 双击设置为 0 //关闭视频进入全屏时的提示
（2）full-screen-api.transition-duration.enter 双击设置为 ‘0 0’ // 去除全屏模式的过渡动画–进入
（3）full-screen-api.transition-duration.leave 双击设置为 ‘0 0’ // 去除全屏模式的过渡动画–退出

# 修改ubuntu合盖动作
修改文件: sudo vim /etc/systemd/logind.conf
HandleLidSwitch=poweroff #关闭盖子时关闭电源。
HandleLidSwitch=hibernate #关闭lid时需要休眠（需要测试hibernate是否工作
HandleLidSwitch=ignore  #什么都不做。
HandleLidSwitch=suspend #(默认值)当盖子关闭时暂停笔记本电脑 -- 耗电。
重启或执行 sudo systemctl restart systemd-logind.service 生效

