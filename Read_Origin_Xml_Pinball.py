# -*- coding: UTF-8 -*-
"""Pinball Mode ONLY"""
import sys, re, codecs
# file_addr = sys.argv[1]
file_addr = r'F:\0518\All_level\pinball\pinball_301342.xml'

file = open(file_addr, r'rb')

buff = file.read() # type:str
buff = buff.replace('PinballSingle', 'shot')
buff = buff.replace('PinballLong', 'long')
buff = buff.replace('PinballSeries', 'seri')
buff = buff.replace('PinballSlip', 'slip')

print('-----------------------')
try:
    BPM = re.findall(r'<BPM>.+</BPM>', buff)[0].lstrip('<BPM>').rstrip('</BPM>')
    ET = re.findall(r'<EnterTimeAdjust>.+</EnterTimeAdjust>', buff)[0].lstrip('<EnterTimeAdjust>').rstrip('</EnterTimeAdjust>')
    title = re.findall(r'<Title>.+</Title>', buff)[0][7:re.findall(r'<Title>.+</Title>', buff)[0].__len__()-8]
except Exception:
    raise ('ERROR: BPM ET')
Note_List = re.findall(r'<Note.*/>', buff)
if Note_List.__len__() == buff.count('long') + buff.count('shot') + buff.count('slip') + buff.count('seri'):
    print('Counter Is Correct ' + title.decode('utf8'))
    print(file_addr)
else:
    raise Exception('Counter Is Not Correct')

title = re.sub(r'[?“/<>*|:]', '', title.decode('utf8'))
file_save_name =  r'F:/0518/PinBall/' + re.findall(r'\d+', file_addr)[1] + '-' + str(ET) + '-' + str(BPM) + '-' + title + '.txt'

# file_save_name =  file_save_name.decode('ascii') + unicode(title, 'utf-8') + u'.txt'
# print(file_save_name)
file_save = codecs.open(file_save_name, 'w','utf-8')
# file_save = open(file_save_name, 'w')
file_save.write('Note_type\tStart_Total_Pos\tEnd_Total_Pos\n')

for item in Note_List:
    try:
        Bar = re.findall(r'Bar="\d+', item)[0].lstrip('Bar="')
        Pos = re.findall(r'Pos="\d+', item)[0].lstrip('Pos="')
        End_Bar = re.findall(r'EndBar="\d+', item)[0].lstrip('EndBar="') if re.findall(r'EndBar="\d+', item).__len__() != 0 else Bar
        End_Pos = re.findall(r'EndPos="\d+', item)[0].lstrip('EndPos="') if re.findall(r'EndPos="\d+', item).__len__() != 0 else Pos
        Note_Type = re.findall(r'note_type="[a-zA-Z0-9]+', item)[0].lstrip('note_type="')
        if Note_Type == 'slip':
            Son = re.findall(r'Son="\d+', item)
            if Son.__len__() == 0:
                Note_Type = 'Slip'
        elif (Note_Type != 'long') and (Note_Type != 'shot') and (Note_Type != 'seri'):
            raise Exception('Include Unknow NoteType: ' + Note_Type)

    except Exception, e:
        print(e)
        print('Error: ' + item)
        raise Exception('Read Note Error')

    Start_Total_Pos = ((int(Bar) - 1) * 4 * 8 + int(Pos) / 2)
    if Note_Type != 'long':
        End_Total_Pos = Start_Total_Pos
    else:
        End_Total_Pos = ((int(End_Bar) - 1) * 4 * 8  + int(End_Pos) / 2)

    write_buf = '%s\t%d\t%d' % (Note_Type, Start_Total_Pos, End_Total_Pos)
    file_save.write(write_buf + '\n')
    # print(write_buf)
file_save.close()

exit()