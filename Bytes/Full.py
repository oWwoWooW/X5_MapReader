# coding=utf-8

import binascii, os, string, re
# 使用前导入对应模式的分析函数
from Bytes_Bubble import Get_Information as getBubble
from Bytes_Idol import Get_Information as getIdol
from Bytes_Pinball import Get_Information as getPinball

FileNameList = []
Folder_addr = r'F:\0518\All_level\Bytes'
Save_Folder_addr = 'C:/Out/'
for abs_dir, sub_dir, file_names in os.walk(Folder_addr):
    for file_name in file_names:
        if string.find(file_name, '.bytes') != -1:
            FileNameList.append('%s%s' % (abs_dir + '\\', file_name))
        else:
            continue

i = 0
for file_addr in FileNameList:
    f = open(file_addr, 'rb+')
    a = f.read()
    hex = binascii.b2a_hex(a)  # type: str
    if hex[0: 4*8 * 2].find('XmlPinballExtend'.encode('hex')) != -1:
        try:
            Map_out = getPinball(hex)
        except NameError as e:
            print('Error | %s\n%s' % (file_addr, e.message))
    elif hex[0: 4*8 * 2].find('XmlIdolExtend'.encode('hex')) != -1:
        try:
            Map_out = getIdol(hex)
        except NameError as e:
            print('Error | %s\n%s' % (file_addr, e.message))
    elif hex[0: 4*8 * 2].find('XmlBubbleExtend'.encode('hex')) != -1:
        try:
            Map_out = getBubble(hex)
        except NameError as e:
            print('Error | %s\n%s' % (file_addr, e.message))
    elif hex[0: 4 * 8 * 2].find('XmlClassicExtend'.encode('hex')) != -1:
        i += 1
        continue
    else:
        raise Exception('Error | 文件头读取错误 %s' % file_addr)

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
    print('Status | No.%i %s %s' % (i, Map_out['Info']['Mode'], FileNameList[i]))
    i += 1
    print('Status | Completed %i/%i' % (i, FileNameList.__len__()))
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
