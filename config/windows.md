# 关闭英特尔显示器节能技术

windows有时会遇到打开白色网站的时候显示器渐渐变亮，打开深色页面的时候显示器反而渐渐变暗的情况

查询之后发现是由于英特尔的显示器节能技术（Intel Display Power Saving Technology, Intel DPST）技术

需要做如下操作关闭英特尔显示器节能技术

1. 打开注册表: 先用Win+R快捷键呼出运行，输入regedit之后确定打开注册表编辑器
2. 定位到计算机`\HKEY_LOCALMACHINE\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001`也可能在0000、0002项目下，重点是`FeatureTestControl`这个名字
3. 修改`FeatureTestControl`的REGDWORD项目。如果是8200则修改为8210，如果是9240就修改为9250
    

本质上是修改"FeatureTestControl"的第五位为1, "FeatureTestControl"为16进制数据, 我们可以对比下步骤3的几个值的例子

| 16进制 | 2进制            |
|--------|------------------|
| 8200   | 1000001000000000 |
| 8210   | 1000001000010000 |
| 9240   | 1001001001000000 |
| 9250   | 1001001001010000 |

以下是linux shell 2进制和16进制互转的脚本
```shell
# 16进制转2进制,这里，obase=2表示输出为二进制,ibase=16表示输入为十六进制,1F是要转换的值。
echo "obase=2; ibase=16; 1F" | bc
# 16进制转2进制,这里，obase=16表示输出为十六进制,ibase=2表示输入为二进制,1F是要转换的值。
echo "obase=16; ibase=2; 11111" | bc
```


9250
# 修改hosts文件

背景: 由于修改hosts文件需要管理员权限所以需要如下操作

1. 打开命令提示符（以管理员身份运行）
2. 输入以下命令
```shell
cd C:\Windows\System32\drivers\etc
# notepad为记事本软件名称,这样能通过管理员权限打开hosts文件
notepad hosts
```

