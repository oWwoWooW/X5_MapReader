# coding=utf-8
import binascii, sys, struct
reload(sys)
sys.setdefaultencoding('utf8')
"""For PowerShell"""
Key = ['BeatPerBar', 'BeatLen', 'EnterTimeAdjust', 'NotePreShow', 'LevelTime', 'BarAmount', 'BeginBarLen',
       'IsFourTrack', 'TrackCount', 'LevelPreTime', 'BPM', 'Title', 'ModeType']
NoteType = ['PinballSingle', 'PinballSlip', 'PinballLong', 'PinballSeries']
# NoteHex存放
Son_List = []


def read_int(data):
    """Hex To int"""
    buf = int(struct.unpack('i', binascii.a2b_hex(data))[0])
    return buf


def read_float(data):
    """Hex To float"""
    buf = float(struct.unpack('f', binascii.a2b_hex(data))[0])
    return round(buf, 2)


def read_note(data):
    Note_Key = ['Note_type', 'Start_Bar', 'Start_Pos', 'End_Bar', 'End_Pos',
                'Son', 'ID', 'EndArea', 'Start_Total_Pos', 'End_Total_Pos']
    Note_Info = dict.fromkeys(Note_Key, '')
    # type: (data) -> str
    # Get Note Information
    buf = data
    Note_Info['ID'] = read_int(buf[0:8])
    NoteType_end = 16 + buf[16:].find('00') + buf[16:].find('00') % 2
    Note_Info['Note_type'] = binascii.a2b_hex(buf[16:NoteType_end])
    if not NoteType.__contains__(Note_Info['Note_type']):
        raise NameError('Error | Note_Type%s' % data)
    if Son_List.__contains__(Note_Info['ID']):
        Note_Info['Note_type'] = Note_Info['Note_type'] + 'X2'
        Son_List.remove(Note_Info['ID'])
    Note_Info['Start_Bar'] = read_int(buf[NoteType_end + 2:NoteType_end + 2 + 8])
    Note_Info['Start_Pos'] = read_int(buf[NoteType_end + 2 + 8:NoteType_end + 2 + 16])
    if Note_Info['Note_type'] == 'PinballLong':
        Note_Info['End_Bar'] = read_int(buf[NoteType_end + 2 + 16:NoteType_end + 2 + 24])
        Note_Info['End_Pos'] = read_int(buf[NoteType_end + 2 + 24:NoteType_end + 2 + 32])
    else:
        Note_Info['End_Bar'] = Note_Info['Start_Bar']
        Note_Info['End_Pos'] = Note_Info['Start_Pos']

    # 有Son比无son多一个int位
    if (buf.__len__() - NoteType_end - 2) / 8 == 9:
        Note_Info['Son'] = read_int(buf[NoteType_end + 2 + 40:NoteType_end + 2 + 48])
        Son_List.append(Note_Info['Son'])
        Note_Info['EndArea'] = '%i|%i' % (read_int(buf[NoteType_end + 2 + 56: NoteType_end + 2 + 64]) + 1,
                                          read_int(buf[NoteType_end + 2 + 64: NoteType_end + 2 + 72]) + 1)
    elif (buf.__len__() - NoteType_end - 2) / 8 == 8:
        Note_Info['EndArea'] = '%i|%i' % (read_int(buf[NoteType_end + 2 + 48: NoteType_end + 2 + 56]) + 1,
                                          read_int(buf[NoteType_end + 2 + 56: NoteType_end + 2 + 64]) + 1)

    # 计算TotalPos
    Start_Total_Pos = ((Note_Info['Start_Bar'] - 1) * 4 * 8 + Note_Info['Start_Pos'] / 2)
    End_Total_Pos = ((Note_Info['End_Bar'] - 1) * 4 * 8 + Note_Info['End_Pos'] / 2)
    Note_Info['Start_Total_Pos'] = Start_Total_Pos
    Note_Info['End_Total_Pos'] = End_Total_Pos
    # return数据格式待定 与matlab对接
    # return_data = '%s\t%d\t%d\t%s\t%s' % (Note_Info['Note_type'],
    #                                       Start_Total_Pos, End_Total_Pos,
    #                                       Note_Info['From_Track'], Note_Info['Target_Track'])
    return Note_Info
    # return Note_Info


def Get_Information(hex):
    Base_Info = dict.fromkeys(Key, '')
    Note_List = []
    p = 0
    # 确认文件头
    if hex[0: 4*8 * 2].find('XmlPinballExtend'.encode('hex')) != -1:
        # print('Map is Pinball')
        Base_Info['ModeType'] = 'Pinball'
        # 跳过文件头
        p += hex[0: 4*8 * 2].find('XmlPinballExtend'.encode('hex')) + 'XmlPinballExtend'.encode('hex').__len__() + 2;
    else:
        raise IOError('File_InCorrect')

    # 内存值转float
    Base_Info['BPM'] = read_float(hex[p:p + 4 * 2])
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

    p_note_str = hex.find('4000000000000000')
    while p_note_str % 2 != 0:
        hex = hex[p_note_str+3:]
        p_note_str = hex.find('4000000000000000')
        if p_note_str is -1 :
            raise NameError('Error | 找不到note标头')
    p_note_str += '4000000000000000'.__len__()
    note_amount = read_int(hex[p_note_str:p_note_str+8])
    hex = hex[p_note_str+8:]
    for i in range(1, note_amount+1):
        # note分隔符为00004040
        ## pinball_300583/44.xml.bytes为00008040
        p_note_end = hex.find('00004040')
        if read_int(hex[0:8]) == i:
            Note_List.append(hex[0:p_note_end])
            hex = hex[p_note_end+'00004040'.__len__():]
        else:
            raise NameError('ID不正确\t%s' % hex[0:p_note_end])

    # while hex.find('Pinball'.encode('hex')) != -1:
    #     p = hex.__len__()
    #     for i in range(0, NoteType.__len__()):
    #         if hex.find(NoteType[i].encode('hex')) != -1 and hex.find(NoteType[i].encode('hex')) < p:
    #             p = hex.find(NoteType[i].encode('hex'))
    #             note_name = NoteType[i]
    #     if p == hex.__len__():
    #         raise NameError('Error | NoteTypeError:%s' % hex)
    #     p_start = p - 8*2
    #     p_end = p + note_name.encode('hex').__len__() + 2 + 4*9*2
    #     check_before = hex[p_start - 8: p_start]
    #     check_after = hex[p_end: p_end + 8]
    #     if check_after != '00004040' and check_before != '00004040':
    #         raise NameError('Error | 分隔符检查错误%s' % hex[p_start - 8:p_end + 8])
    #     Note_List.append(hex[p_start: p_end])
    #     hex = hex[p_end - 8:]

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


# # 单文件测试部分
# file_addr = r'F:\0518\All_level\Bytes_pinball\pinball_300544.xml.bytes'
# f = open(file_addr, 'rb+')
# a = f.read()
# hex = binascii.b2a_hex(a)  # type: str
# try:
#     Map_out = Get_Information(hex)
#     p=9
# except NameError as e:
#     print('Error | %s\n%s' % (file_addr, e.message))