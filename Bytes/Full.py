# Bytes2txt
# 2019-4-30
# L13 定义bytes文件目录，主程序会自动检查文件名调用不同程序
# L14 输出txt目录

import binascii, os, string, re
# 使用前导入对应模式的分析函数
from Bytes_Bubble import Get_Information as getBubble
from Bytes_Idol import Get_Information as getIdol
from Bytes_Pinball import Get_Information as getPinball

fileNameList = []
inputFolder = 'D:/x5/882556254_981_2.3.2.0_20190410110625_1650835641_apkupdate/assets/zips/assetbundles/level/all'
saveFolder = 'D:/x5/882556254_981_2.3.2.0_20190410110625_1650835641_apkupdate/assets/zips/assetbundles/level/'
f_log = open(saveFolder + 'log.txt', 'w')

for abs_dir, sub_dir, file_names in os.walk(inputFolder):
    for file_name in file_names:
        if str.find(file_name, '.bytes') != -1:
            fileNameList.append('%s%s' % (abs_dir + '\\', file_name))
        else:
            continue

i = 0
for file_addr in fileNameList:
    f = open(file_addr, 'rb+')
    a = f.read()
    hex = binascii.b2a_hex(a)  # type: str
    try:
        if str(a[0:4 * 8 * 2]).find('XmlPinballExtend') != -1:
            Map_out = getPinball(hex)
        elif str(a[0: 4 * 8 * 2]).find('XmlIdolExtend') != -1:
            Map_out = getIdol(hex)
        elif str(a[0: 4 * 8 * 2]).find('XmlBubbleExtend') != -1:
            Map_out = getBubble(hex)
        elif str(a[0: 4 * 8 * 2]).find('XmlClassicExtend') != -1:
            i += 1
            continue
        else:
            f_log.write('Error | 文件头读取错误 %s\n' % file_addr)
            continue
    except Exception as e:
        f_log.write('Error | %s\t%s\n' % (file_addr, e.message))
        raise Exception(e.message)

    buf_info = ''
    # 补写BgmId
    Bgmid = re.findall(re.compile(r'(?<=[bubble pinball idol].)\d{6}'), file_addr)
    Map_out['Info']['BgmId'] = Bgmid[Bgmid.__len__() - 1]
    for key, value in Map_out['Info'].items():
        # 首行写入Map_Info
        buf_info += '%s:%s\t' % (key, str(value))
    buf_info += '\n'

    buf_notes = ''
    for item in Map_out['Notes']:
        # Bubble的Type为数字 强制转换
        buf_notes += '%s\t%i\t%i\n' \
                     % (str(item['Note_type']), item['Start_Total_Pos'], item['End_Total_Pos'])
    print('Status | No.%i %s %s' % (i, Map_out['Info']['ModeType'], fileNameList[i]))
    i += 1    
    try:
        # 文件名规范化
        title = re.sub(re.compile('[<>/\\|:"*,?]', re.S), "", Map_out['Info']['Title'])
        f_save = open('%s%s-%s.txt' % (saveFolder, title,
                                       Map_out['Info']['ModeType']), 'w', encoding='utf8')
        f_save.write(buf_info)
        f_save.write(buf_notes)
        f_save.close()
        print('Status | Completed %i/%i' % (i, fileNameList.__len__()))
    except Exception:
        print('Status | Error %i/%i' % (i, fileNameList.__len__()))
f_log.close()
print('OK')
