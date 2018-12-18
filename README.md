# X5_MapReader -- 2018/11/21
## ----Bytes----(建议使用)
### 介绍
  读取.bytes文件，读取谱面信息并输出到固定文件夹下
  调用Matlab，读取上步生成的谱面信息绘图并导出爆气点坐标
### 版本
  Python 2.7.14
  Matlab 2017a
### 使用
  0.  游戏包中解出.bytes文件，放入一个文件夹中
  1.  Full.py中指定Folder_addr为存放.bytes的文件夹；Save_Folder_addr为解析出的谱面文件存放的文件夹(建议将所有bytes文件存放到同一个文件夹下,不要有其他文件)
      运行,函数会自动根据标头调用不同模式处理函数
  2.  在bytesFull.m中，修改Folder到上一步保存到的文件夹(Save_Folder_addr)，根据需要调用(SProcess/Process)，默认使用Sprocess
      SProcess ：连击数-爆气图  Process：时间-爆气图
  3.  在SProcess.m或Process.m中修改赛季参数(CHECK量)以及相关文件保存位置（结尾两处）
  4.  运行bytesFull.m
  5.  生成目录下查看文件
### 18/11/21计算规则：
各类型Note得分经过测试已标注在文件中(均为无分数BUFF下SP判定的标准分数)
爆气时间简单测试结果为160Pos，Matlab处理文件已修正
### 注意
  1.  更多已提取信息请检查Py部分的各模式处理函数Note_Key
  2.  Idol的Track似乎有误，未检查
  3.  Note提取验证完毕，各分数检查完毕
  4.  Pinball单独两文件note分隔符与其他不同，已注释
  5.  Pinball中作为Son的Note在Type后加X2 [已验证Serial的Son无分数加成 按Serial处理]
## ----Matlab_new----
### 介绍
  读取XML文件，转换为TXT或直接生成图
### 版本
  Matlab 2017a
### 使用
  1.  Full.m中修改文件夹位置
  2.  Process.m中修改部分参数
### 注意
  1.  未测试
  2.  未实现秒单位的分数直方图
# X5_MapReader -- 2018/04/19
## ----Old----
### 介绍
  Python:读取XML文件，转换为TXT
  Matlab：读取txt，绘图
### 版本
  Python 2.7
  Matlab 2017a
### 使用
  1.  通过powershell调用py转换.xml到.txt
  2.  通过matlab调用对应函数读取txt生成图
### 注意
  1.  ps执行时极个别图文件名称编码报错，请注意提示并记录
  1.1 ps中报错的文件删除.py文件 行27 处的.encode('gbk')后手动指定file_addr直接执行，或者写try
  2.  Matlab另写脚本,读取txt文件批量执行函数
  3.  注意修改.m文件中图像保存位置
