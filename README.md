# X5_MapReader -- 2019/04/30
## ----Bytes----
### 介绍
  读取.bytes文件，读取谱面信息并输出到固定文件夹下
  调用Matlab，读取上步生成的谱面信息绘图并导出爆气点坐标
  为防止图谱在赛季间发生变化，各赛季的更新需重新提取并计算一遍bytes文件，并重新测试赛季相关参数
### 版本
  Python 3.7.2
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
### 2018/11/21计算规则：
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
  与Bytes内文件相同
### 版本
  Matlab 2017a
### 使用
  1.  Full.m中修改文件夹位置
  2.  Process.m中修改部分参数
### 注意
  1.  未测试
  2.  未实现秒单位的分数直方图