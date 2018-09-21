# coding=utf-8
import binascii, sys

# file_addr = './test.bytes'

# file_addr = sys.argv[1]
"""For PowerShell"""
file_addr = r'C:\Users\0\Documents\10018365_com.tencent.tmgp.qqx5_u117_1.2.11_bd2b0d\assets\81'
Key = ['BeatPerBar', 'BeatLen', 'EnterTimeAdjust', 'NotePreShow', 'LevelTime', 'BarAmount', 'BeginBarLen',
       'IsFourTrack', 'TrackCount', 'LevelPreTime']


def read_4_bytes(data):
    # type: (data) -> str
    """Read 4Bytes Return Resort Data"""
    if not isinstance(data, str):
        raise TypeError('Data is not String')
    if data.__len__() != 8:
        raise TypeError('Data Bits Amounts Error')
    temp = [data[6], data[7], data[4], data[5], data[2], data[3], data[0], data[1]]
    o = ''.join(temp)
    return int(o, 16)


def read_note(data):
    Note_Key = ['Note_type', 'Start_Bar', 'Start_Pos', 'From_Track', 'Target_Track', 'End_Bar', 'End_Pos']
    Note_Info = dict.fromkeys(Note_Key, '')
    # type: (data) -> str
    """Read Note Hex Return Box"""
    if data.__len__() != 48 * 2:
        raise ImportError('Note Hex Size Is Not Correct')
    if data[0:4 * 2] != '00000000':
        raise ImportError('Note Hex Head Is Not Correct')
    buf = data

    # Note Type Check
    if buf.count('long'.encode('hex')) == 1:
        Note_type = 'long'
    elif buf.count('shot'.encode('hex')) == 1:
        Note_type = 'shot'
    elif buf.count('slip'.encode('hex')) == 1:
        Note_type = 'slip'
    else:
        Note_type = 'Null'
        raise ImportError('Note Type Error')
    Note_Info['Note_type'] = Note_type

    # Get Note Information
    Note_Info['Start_Bar'] = read_4_bytes(buf[4 * 2:8 * 2])
    Note_Info['Start_Pos'] = read_4_bytes(buf[8 * 2:12 * 2])
    if (Note_type == 'long') or (Note_type == 'shot'):
        Note_Info['From_Track'] = buf[16 * 2:18 * 2].decode('hex')
    else:
        Note_Info['From_Track'] = buf[21 * 2:23 * 2].decode('hex')
    Note_Info['Target_Track'] = buf[28 * 2:30 * 2].decode('hex')
    Note_Info['End_Bar'] = read_4_bytes(buf[40 * 2:44 * 2])
    Note_Info['End_Pos'] = read_4_bytes(buf[44 * 2:48 * 2])
    if Note_Info['From_Track'] != 'L1' and \
            Note_Info['From_Track'] != 'L2' and \
            Note_Info['From_Track'] != 'R1' and \
            Note_Info['From_Track'] != 'MD' and\
            Note_Info['From_Track'] != 'R2':
        raise ImportError("Note From_Track Read Error!")
    # return_data = '%s\t%d\t%d\t%d\t%d\t%s\t%s' % (Note_Info['Note_type'],
    #                                               Note_Info['Start_Bar'], Note_Info['Start_Pos'],
    #                                               Note_Info['End_Bar'], Note_Info['End_Pos'],
    #                                               Note_Info['From_Track'], Note_Info['Target_Track'])
    Start_Total_Pos = ((Note_Info['Start_Bar'] - 1) * 4 * 8 + Note_Info['Start_Pos'] / 2) / 8
    if (Note_Info['Note_type'] == 'shot') or Note_Info['Note_type'] == 'slip':
        End_Total_Pos = Start_Total_Pos
    else:
        End_Total_Pos = ((Note_Info['End_Bar'] - 1) * 4 * 8 + Note_Info['End_Pos'] / 2) / 8
    return_data = '%s\t%d\t%d\t%s\t%s' % (Note_Info['Note_type'],
                                          Start_Total_Pos, End_Total_Pos,
                                          Note_Info['From_Track'], Note_Info['Target_Track'])
    return return_data
    # return Note_Info


def Get_Information(hex):
    Base_Info = dict.fromkeys(Key, '')
    p = 0
    if hex[p:p + 17 * 2] != '0d000000586d6c49646f6c457874656e64':
        raise IOError('File_InCorrect')
        exit('ERROR_Bytes_File')
    p += 17 * 2
    hex = hex.replace('Left'.encode('hex'), 'L'.encode('hex'))  # Left   ->L
    hex = hex.replace('Right'.encode('hex'), 'R'.encode('hex'))  # Right  ->R
    hex = hex.replace('short'.encode('hex'), 'shot'.encode('hex'))  # short  ->shot
    hex = hex.replace('Middle'.encode('hex'), 'MD'.encode('hex')) # Middle ->MD
    p += 5 * 2
    Base_Info['BeatPerBar'] = read_4_bytes(hex[p:p + 4 * 2])
    Base_Info['BeatLen'] = read_4_bytes(hex[p + 4 * 2:p + 8 * 2])
    Base_Info['EnterTimeAdjust'] = read_4_bytes(hex[p + 8 * 2:p + 12 * 2])
    Base_Info['NotePreShow'] = read_4_bytes(hex[p + 12 * 2:p + 16 * 2])
    Base_Info['LevelTime'] = read_4_bytes(hex[p + 16 * 2:p + 20 * 2])
    Base_Info['BarAmount'] = read_4_bytes(hex[p + 20 * 2:p + 24 * 2])
    Base_Info['BeginBarLen'] = read_4_bytes(hex[p + 24 * 2:p + 28 * 2])
    if hex[p + 28 * 2:p + 29 * 2] == '01':
        Base_Info['IsFourTrack'] = True
    else:
        Base_Info['IsFourTrack'] = False
    Base_Info['TrackCount'] = read_4_bytes(hex[p + 29 * 2:p + 33 * 2])
    Base_Info['LevelPreTime'] = read_4_bytes(hex[p + 33 * 2:p + 37 * 2])
    if hex.find('ffffffff') != -1:
        t1 = hex.find('ffffffff') + 8 * 2
    else:
        raise ImportError('Cannot Find Title')
    t2 = hex[t1:].find('00') + hex[t1:].find('00')%2
    title = hex[t1:t1 + t2].decode('hex').decode('utf-8')

    p_s = hex.find('shot'.encode('hex')) if hex.find('shot'.encode('hex')) != -1 else 100000
    p_l = hex.find('long'.encode('hex')) if hex.find('long'.encode('hex')) != -1 else 100000
    p_p = hex.find('slip'.encode('hex')) if hex.find('slip'.encode('hex')) != -1 else 100000
    p = min(p_l, p_p, p_s)
    # Locate NoteType
    # print(hex[p:p+4*2])
    p -= 35 * 2
    if hex[p:p + 4 * 2] != '00000000':
        if hex[p - 4 * 2:p] == '01000000':
            p -= 4 * 2
        else:
            print('Error First Note is Combine')
    # try:
    #     p2 = hex.index('04000000020000000000000000000000000000000000000D000000020000000400000002') - 12*2
    # except Exception:
    #     print('Cant Not Find End Of Note Hex')
    #     exit()

    Position_Last_shot = hex.rfind('shot'.encode('hex'))
    Position_Last_long = hex.rfind('long'.encode('hex'))
    Position_Last_slip = hex.rfind('slip'.encode('hex'))
    Position_Last = max(Position_Last_slip, Position_Last_long, Position_Last_shot) + 2 * 13
    hex = hex[p:Position_Last]
    Total_Amount = hex.count('shot'.encode('hex')) + hex.count('long'.encode('hex')) + hex.count('slip'.encode('hex'))

    Note_List = []
    while True:
        if hex.__len__() <= 0:
            print('Success Spilt')
            break
        if hex[0:4 * 2] == '00000000':
            note_hex = hex[0:48 * 2]
            Note_List.append(note_hex)
            # print('Number:' + str(Note_List.__len__()) + ' |' + note_hex)
            hex = hex[48 * 2:]
        elif hex[0:4 * 2] == '01000000':
            Comb_aount = read_4_bytes(hex[4 * 2:8 * 2])
            hex = hex[8 * 2:]
            for i in range(0, Comb_aount):
                note_hex = '00000000' + hex[0:44 * 2]
                Note_List.append(note_hex)
                # print('Number:' + str(Note_List.__len__()) + ' |' + note_hex)
                hex = hex[44 * 2:]

        else:
            raise NameError('Cannot Find Start Symbol')
    # print 'Total Amount : ' + str(Total_Amount)
    if Note_List.__len__() == Total_Amount:
        print 'Number Correct!'
    else:
        raise IOError('Note Number Is Not Correct')
    # Note_List Is Done

    f2 = open('C:\\Users\\0\\3D Objects\\idol\\New\\' + str(Base_Info['EnterTimeAdjust']) + '-' + title + '.txt', 'a')
    # f2.write('Note_type\tStart_Bar\tStart_Pos\tEnd_Bar\tEnd_Pos\tFrom_Track\tTarget_Track\n')
    f2.write('Note_type\tStart_Total_Pos\tEnd_Total_Pos\tFrom_Track\tTarget_Track\n')
    i = 0
    for item in Note_List:
        try:
            Note_Box_Single = read_note(item)
            i += 1
        except IOError as e:
            print(e)
            exit()
        except Exception as e:
            print e
            exit()
        # print(Note_Box_Single)
        # print('State|Note: ' + str(i) + ' SUCCESS')
        f2.write(Note_Box_Single + '\n')
    f2.close()
    print 'End:' + 'title'
    exit()


f = open(file_addr, 'rb+')
a = f.read()
hex = binascii.b2a_hex(a)  # type: str
buff = hex.split('XmlIdolExtend'.encode('hex'))
counter = 0
for item in buff:
    if counter == 0:
        counter += 1
        continue
    try:
        Get_Information('0d000000586d6c49646f6c457874656e64' + item)
    except NameError:
        print('Skip')
        continue
    counter += 1
    print counter