# py部分MATLAB重写中
# X5_MapReader
# 介绍
  Python:读取XML文件，转换为TXT
  Matlab：读取txt，绘图
# 版本
  Python 2.7
  Matlab 2017a
# 使用
  1.  通过powershell调用py转换.xml到.txt
  2.  通过matlab调用对应函数读取txt生成图
# 注意
  1.  ps执行时极个别图文件名称编码报错，请注意提示并记录
  1.1 ps中报错的文件删除.py文件 行27 处的.encode('gbk')后手动指定file_addr直接执行，或者写try
  2.  Matlab另写脚本,读取txt文件批量执行函数
  3.  注意修改.m文件中图像保存位置
