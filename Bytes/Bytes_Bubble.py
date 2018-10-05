# coding=utf-8
import binascii, sys, struct
reload(sys)
sys.setdefaultencoding('utf8')
"""For PowerShell"""
# file_addr = r'F:\0518\All_level\Bytes\bubble_200004.xml.bytes'
Key = ['BeatPerBar', 'BeatLen', 'EnterTimeAdjust', 'NotePreShow', 'LevelTime', 'BarAmount', 'BeginBarLen',
       'IsFourTrack', 'TrackCount', 'LevelPreTime', 'Bpm', 'Title']


def read_int(data):
    """Hex To int"""
    buf = int(struct.unpack('i', binascii.a2b_hex(data))[0])
    return buf


def read_float(data):
    """Hex To float"""
    buf = float(struct.unpack('f', binascii.a2b_hex(data))[0])
    return round(buf, 2)


def read_note(data):
    Note_Key = ['Note_type', 'Start_Bar', 'Start_Pos', 'From_Track', 'Target_Track', 'End_Bar', 'End_Pos',
                'Screen_Pos_X', 'Screen_Pos_Y', 'Fly_Track_Name', 'ID', 'MoveType', 'MoveDegree', 'FlyDegree',
                'Start_Total_Pos', 'End_Total_Pos']
    Note_Info = dict.fromkeys(Note_Key, '')
    # type: (data) -> str
    # Get Note Information
    buf = data
    Note_Info['Start_Bar'] = read_int(buf[0 :4 * 2])
    Note_Info['Start_Pos'] = read_int(buf[4 * 2:8 * 2])
    Note_Info['From_Track'] = read_int(buf[8 * 2:12 * 2]); Note_Info['Target_Track'] = Note_Info['From_Track']
    Note_Info['Note_type'] = read_int(buf[12 * 2:16 * 2])
    if data.__len__() == 190:
        Note_Info['End_Bar'] = read_int(buf[16 * 2:20 * 2])
        Note_Info['End_Pos'] = read_int(buf[20 * 2:24 * 2])
        Note_Info['ID'] = read_int(buf[24 * 2:28 * 2])
        Note_Info['MoveType'] = binascii.a2b_hex(buf[36 * 2:48 * 2])
        Note_Info['MoveDegree'] = read_float(buf[49 * 2:53 * 2])
        Note_Info['Fly_Track_Name'] = binascii.a2b_hex(buf[61 * 2:70 * 2])
        Note_Info['FlyDegree'] = read_float(buf[71 * 2:75 * 2])
        Note_Info['Screen_Pos_X'] = read_int(buf[79 * 2:83 * 2])
        Note_Info['Screen_Pos_Y'] = read_int(buf[83 * 2:87 * 2])

    if data.__len__() == 148:
        Note_Info['End_Bar'] = Note_Info['Start_Bar']
        Note_Info['End_Pos'] = Note_Info['Start_Pos']
        Note_Info['Screen_Pos_X'] = read_int(buf[40 * 2:44 * 2])
        Note_Info['Screen_Pos_Y'] = read_int(buf[44 * 2:48 * 2])
        Note_Info['Fly_Track_Name'] = binascii.a2b_hex(buf[60 * 2:69 * 2])
        Note_Info['Screen_Pos_Y'] = read_float(buf[70 * 2:74 * 2])

    # 计算TotalPos
    Start_Total_Pos = ((Note_Info['Start_Bar'] - 1) * 4 * 8 + Note_Info['Start_Pos'] / 2) / 8
    End_Total_Pos = ((Note_Info['End_Bar'] - 1) * 4 * 8 + Note_Info['End_Pos'] / 2) / 8
    Note_Info['Start_Total_Pos'] = Start_Total_Pos
    Note_Info['End_Total_Pos'] = End_Total_Pos
    # return数据格式待定 与matlab对接
    return_data = '%s\t%d\t%d\t%s\t%s' % (Note_Info['Note_type'],
                                          Start_Total_Pos, End_Total_Pos,
                                          Note_Info['From_Track'], Note_Info['Target_Track'])
    return Note_Info
    # return Note_Info


def Get_Information(hex):
    Base_Info = dict.fromkeys(Key, '')
    p = 0
    # 确认文件头
    if hex[0: 4*8 * 2].find('XmlBubbleExtend'.encode('hex')) != -1:
        print('Map is Bubble')
        # 跳过文件头
        p += hex[0: 4*8 * 2].find('XmlBubbleExtend'.encode('hex')) + 'XmlBubbleExtend'.encode('hex').__len__() + 2;
    else:
        raise IOError('File_InCorrect')
        exit('ERROR_Bytes_File')

    # 修正MoveTrack关键词长度 全部指定4中文字
    # 10/05 命名过于沙雕 放弃分析

    hex = hex.replace('对称'.encode('hex'), '')
    hex = hex.replace('滑动β'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('滑动支线1.5'.encode('hex'), '滑你爷爷'.encode('hex'))
    hex = hex.replace('长按三叶草'.encode('hex'), '长按三叶'.encode('hex'))
    hex = hex.replace('长按尖角2拍'.encode('hex'), '长按三叶'.encode('hex'))
    hex = hex.replace('长按Z型'.encode('hex'), '长按你爸'.encode('hex'))
    hex = hex.replace('长按眼睛1'.encode('hex'), '长按你妈'.encode('hex'))
    hex = hex.replace('长按弧'.encode('hex'), '长按你姐'.encode('hex'))
    hex = hex.replace('长按你姐线'.encode('hex'), '长按你姐'.encode('hex'))
    hex = hex.replace('滑动S型'.encode('hex'), '滑动你死'.encode('hex'))
    hex = hex.replace('滑动Z型'.encode('hex'), '滑动你死'.encode('hex'))
    hex = hex.replace('滑动直角型'.encode('hex'), '滑动直角'.encode('hex'))
    hex = hex.replace('滑动直角形'.encode('hex'), '滑动直角'.encode('hex'))
    hex = hex.replace('滑动直角边'.encode('hex'), '滑动直角'.encode('hex'))
    hex = hex.replace('滑动M型'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('滑动M'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('滑动反手弧线'.encode('hex'), '滑动反手'.encode('hex'))
    hex = hex.replace('长按ILU2'.encode('hex'), '长按搞基'.encode('hex'))
    hex = hex.replace('长按ILU'.encode('hex'), '长按搞基'.encode('hex'))
    hex = hex.replace('长按S型'.encode('hex'), '长按有病'.encode('hex'))
    hex = hex.replace('长按V型'.encode('hex'), '长按有病'.encode('hex'))
    hex = hex.replace('长按U型'.encode('hex'), '长按有病'.encode('hex'))
    hex = hex.replace('长按S形'.encode('hex'), '长按有病'.encode('hex'))
    hex = hex.replace('长按L型'.encode('hex'), '长按有病'.encode('hex'))
    hex = hex.replace('滑动弧'.encode('hex'), '滑动去世'.encode('hex'))

    hex = hex.replace('滑动去世线'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('滑动弧对线'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('长按直线2'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按直线1.5'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按波浪2拍'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按无限型'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按蝴蝶右'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按蝴蝶左'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('滑动1拍直线'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('滑动2拍弧线'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('滑动2拍曲线'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('滑动菱形3拍'.encode('hex'), '滑动去世'.encode('hex'))
    hex = hex.replace('长按2拍弧线'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按倒L型'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按2拍直角'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按心电心左'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('长按心电心右'.encode('hex'), '长按去世'.encode('hex'))
    hex = hex.replace('滑动直角1.5'.encode('hex'), '滑动直角'.encode('hex'))



    # 内存值转float
    Base_Info['Bpm'] = read_float(hex[p:p + 4 * 2])
    p += 4 * 2
    Base_Info['BeatPerBar'] = read_int(hex[p:p + 4 * 2])
    Base_Info['BeatLen'] = read_int(hex[p + 4 * 2:p + 8 * 2])
    Base_Info['EnterTimeAdjust'] = read_int(hex[p + 8 * 2:p + 12 * 2])
    Base_Info['NotePreShow'] = read_float(hex[p + 12 * 2:p + 16 * 2])   # 确定是float
    Base_Info['LevelTime'] = read_int(hex[p + 16 * 2:p + 20 * 2])
    Base_Info['BarAmount'] = read_int(hex[p + 20 * 2:p + 24 * 2])
    Base_Info['BeginBarLen'] = read_int(hex[p + 24 * 2:p + 28 * 2])
    if hex[p + 28 * 2:p + 29 * 2] == '01':
        Base_Info['IsFourTrack'] = True
    else:
        Base_Info['IsFourTrack'] = False
    Base_Info['TrackCount'] = read_int(hex[p + 29 * 2:p + 33 * 2])
    Base_Info['LevelPreTime'] = read_int(hex[p + 33 * 2:p + 37 * 2])
    # 定位Title开头
    if hex.find('ffffffff') != -1:
        t1 = hex.find('ffffffff') + 8 * 2
    else:
        raise ImportError('Cannot Find Title')
    # 定位Title结束 防止位数错误对2取余数
    t2 = hex[t1:].find('00') + hex[t1:].find('00')%2
    Base_Info['Title'] = binascii.a2b_hex(hex[t1:t1 + t2])
    # 确认各Note数据类型(0->MoveTrack 1->FlyTrackONLY)
    note_type = []
    # NoteHex存放
    Note_List = []
    p = hex.find('波浪形'.encode('hex'))
    buf = hex[p:]
    while buf.find('波浪形'.encode('hex'), '波浪形'.encode('hex').__len__()-1) != -1:
        p1 = buf.find('波浪形'.encode('hex'), '波浪形'.encode('hex').__len__()-1)
        if p1 == 190 or p1 == 188:
            note_type.append(0)
        elif p1 == 150 or p1 == 148:
            note_type.append(1)
        else:
            # 若长度不为 190 188 150 148 则MoveTrack名字可能不为4中文
            raise NameError('Error|Position: %i|\n%s' % (note_type.__len__(), buf[p1-140:p1]))
        buf = buf[p1:]
    if p1 == 190 or p1 == 150:
        note_type.append(0)
    elif p1 == 188 or p1 == 148:
        note_type.append(1)

    p = hex.find('波浪形'.encode('hex'))
    if note_type[0] == 0:
        Note_List.append(hex[p - 122: p + 68])
        buf = hex[p+68:]
    else:
        Note_List.append((hex[p - 120: p + 28]))
        buf = hex[p + 28:]

    for i in range(1, note_type.__len__()):
        if note_type[i] == 0:
            Note_List.append(buf[0: 190])
            buf = buf[190:]
        else:
            Note_List.append(buf[0: 148])
            buf = buf[148:]
    # Locate NoteType

    i = 0
    # Notes总表
    Notes_List = []
    for item in Note_List:
        try:
            Note_Box_Single = read_note(item)
            Notes_List.append(Note_Box_Single)
        except Exception as e:
            raise e
    Map_out = {'Info': Base_Info, 'Notes': Notes_List}
    return Map_out

