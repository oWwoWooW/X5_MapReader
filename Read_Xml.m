% XML_file_addr = 'D:\X5\idol_100939.xml';
function status = Read_Xml(XML_file_addr)
    XML_file = xmlread(XML_file_addr);
    Info_KeyWords = ["BPM" 'BeatPerBar' 'BeatLen'...
        'EnterTimeAdjust' 'NotePreShow'...
        'LevelTime' 'BarAmount' 'BeginBarLen'... 
        'IsFourTrack' 'TrackCount' 'LevelPreTime'...
        'Title' 'Artist' 'FilePath'...
        'IndicatorResetPos' ];
    Info_Martix = Info_KeyWords;
    % 子节点形式提取
    % Level_Info_Node = XML_file.getElementsByTagName('LevelInfo');
    % if Level_Info_Node.getLength ~= 1
    %     error('ERROR|Level_Info_Node Not Correct');
    % end
    % Level_Info_Node = Level_Info_Node.item(0);
    % for i = 0:Level_Info_Node.getLength-1
    %     if isempty(regexp(string(Level_Info_Node.item(i).getTextContent), '\n ', 'start')) 
    %         value = Level_Info_Node.item(i).getTextContent;
    %         value_index = find( (Info_KeyWords == string(Level_Info_Node.item(i).getNodeName)) == 1 );
    %         Info_Martix(2, value_index) = value;
    %     else
    %         continue;
    %     end
    % end

    % 直接div提取
    for i = 1:max(size(Info_KeyWords))
        Select_Node = XML_file.getElementsByTagName(Info_KeyWords(1, i));
        if Select_Node.getLength ~= 1
            error('ERROR|%s_Info_Node Not Correct', Info_KeyWords(1, i));
        end
        Info_Martix(2, i) = string(Select_Node.item(0).getTextContent);

    end

    Note_Nodes = XML_file.getElementsByTagName('NoteInfo');
    Note_Nodes = Note_Nodes.item(0);
    Note_Nodes = Note_Nodes.getElementsByTagName('Note');

    Note_Attr_KeyWords = ["Bar" "Pos" "from_track"...
        "target_track" "note_type" "EndBar"...
        "EndPos" "end_track"];
    Note_Attr_KeyWords_cell = {'Bar' 'Pos' 'from_track'...
        'target_track' 'note_type' 'EndBar'...
        'EndPos' 'end_track'};
    Not_Typ_id = find((Note_Attr_KeyWords == 'note_type') ==1);
    End_Bar_id = find((Note_Attr_KeyWords == 'EndBar') ==1);
    End_Pos_id = find((Note_Attr_KeyWords == 'EndPos') ==1);
    Str_Bar_id = find((Note_Attr_KeyWords == 'Bar') ==1);
    Str_Pos_id = find((Note_Attr_KeyWords == 'Pos') ==1);
    End_Tra_id = find((Note_Attr_KeyWords == 'end_track') ==1);
    Fro_Tra_id = find((Note_Attr_KeyWords == 'from_track') ==1);
    Note_Attr_number = max(size(Note_Attr_KeyWords));
    Note_Martix = cell(Note_Nodes.getLength, Note_Attr_number);
    note_available_count = 1;
    for i = 0:Note_Nodes.getLength - 1
        Note_Node = Note_Nodes.item(i);
        if ~Note_Node.hasAttribute('Pos')
            continue;
        end
        for j = 1:Note_Attr_number
            value = Note_Node.getAttribute(Note_Attr_KeyWords(j));
            if ~isnan(str2double(value))
                value = str2double(value);
            else
                value = string(value);
                value = value.replace('Left', 'L');
                value = value.replace('Right', 'R');
                value = value.replace('short', 'shot');
                value = value.replace('Middle', 'MD');
            end
            Note_Martix{note_available_count, j} = value;
        end  
        if (Note_Martix{note_available_count, Not_Typ_id} == "shot") ||...
                (Note_Martix{note_available_count, Not_Typ_id} ==  "slip")
            Note_Martix{note_available_count, End_Bar_id} = Note_Martix{note_available_count, Str_Bar_id};
            Note_Martix{note_available_count, End_Pos_id} = Note_Martix{note_available_count, Str_Pos_id};
        end    
        if Note_Martix{note_available_count, Not_Typ_id} ==  "slip"
            Note_Martix{note_available_count, Fro_Tra_id} = Note_Martix{note_available_count, End_Tra_id};
        end
        note_available_count = note_available_count + 1;
    end
    Note_Martix = Note_Martix(1:note_available_count - 1, :);

    %To Table
    Note_Martix_table = cell2table(Note_Martix, 'VariableNames', Note_Attr_KeyWords_cell);
    Note_Martix_table_changed = Note_Martix_table;
    Note_Martix_table_changed.Pos = (Note_Martix_table.Bar-1)*4*8 + Note_Martix_table.Pos/2;
    Note_Martix_table_changed.EndPos = (Note_Martix_table.EndBar-1)*4*8 + Note_Martix_table.EndPos/2;
    Note_Martix_table_changed.Bar = []; Note_Martix_table_changed.EndBar = [];
    file = fopen('D:/re.txt', 'w');

    for i = 1:size(Note_Martix_table_changed, 1)
        fprintf(file, '%s\t%d\t%d\t%s\t%s\n', Note_Martix_table_changed.note_type(i),...
            Note_Martix_table_changed.Pos(i), Note_Martix_table_changed.EndPos(i),...
            Note_Martix_table_changed.from_track(i), Note_Martix_table_changed.target_track(i));
    end
    fclose(file);
    status = 1;
end