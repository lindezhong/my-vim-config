# 火狐全屏时黑一下晃眼睛问题解决办法
地址栏输入 about:config，回车进入配置页面。分别搜索下面三项，功能看注释
（1）full-screen-api.warning.timeout 双击设置为 0 //关闭视频进入全屏时的提示
（2）full-screen-api.transition-duration.enter 双击设置为 ‘0 0’ // 去除全屏模式的过渡动画–进入
（3）full-screen-api.transition-duration.leave 双击设置为 ‘0 0’ // 去除全屏模式的过渡动画–退出
