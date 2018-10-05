# coding=utf-8

import binascii, os, string
from Bytes_Bubble import Get_Information

FileNameList = []
Folder_addr = r'F:\0518\All_level\Bytes_bubble'
for abs_dir, sub_dir, file_names in os.walk(Folder_addr):
    for file_name in file_names:
        if string.find(file_name, '.bytes') != -1:
            FileNameList.append('%s%s' % (abs_dir+'\\', file_name))
        else:
            continue
i = 0
for file_addr in FileNameList:
    # file_addr = r'F:\0518\All_level\Bytes\bubble_200004.xml.bytes'
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
        buf_notes += '%i\t%i\t%i\n' \
                     % (item['Note_type'], item['Start_Total_Pos'], item['End_Total_Pos'])
    i += 1
    print('%i/%i' % (i, FileNameList.__len__()))
print 'OK'