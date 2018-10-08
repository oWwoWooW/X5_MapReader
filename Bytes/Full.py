# coding=utf-8

import binascii, os, string, re
# 使用前导入对应模式的分析函数
from Bytes_Bubble import Get_Information
# from Bytes_Idol import Get_Information
FileNameList = []
Folder_addr = r'F:\0518\All_level\Bytes_Bubble'
Save_Folder_addr = 'C:/Out/'
for abs_dir, sub_dir, file_names in os.walk(Folder_addr):
    for file_name in file_names:
        if string.find(file_name, '.bytes') != -1:
            FileNameList.append('%s%s' % (abs_dir+'\\', file_name))
        else:
            continue

i = 0
for file_addr in FileNameList:
    f = open(file_addr, 'rb+')
    a = f.read()
    hex = binascii.b2a_hex(a)  # type: str
    try:
        Map_out = Get_Information(hex)
    except NameError as e:
        print('Error | %s\n%s' % (file_addr, e.message))
    buf_info = ''
    for key, value in Map_out['Info'].items():
        # 首行写入Map_Info
        buf_info += '%s:%s\t' % (key, str(value))
    buf_info += '\n'

    buf_notes = ''
    for item in Map_out['Notes']:
        # Bubble的Type为数字 强制转换
        buf_notes += '%s\t%i\t%i\n' \
                     % (str(item['Note_type']), item['Start_Total_Pos'], item['End_Total_Pos'])
    i += 1
    print('%i/%i' % (i, FileNameList.__len__()))
    try:
        # 文件名规范化
        title = re.sub(re.compile('[<>/\\|:"*,?]', re.S), "", Map_out['Info']['Title'])
        f_save = open('%s%s-%s.txt' % (Save_Folder_addr.decode('utf8'), title.decode('utf8'),
                                       Map_out['Info']['Mode']), 'w')
        f_save.write(buf_info)
        f_save.write(buf_notes)
        f_save.close()
    except Exception:
        print('ws')
print 'OK'