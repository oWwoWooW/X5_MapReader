% XML_file_addr = 'D:\X5\idol_100939.xml';
function status = Read_Xml(XML_file_addr)
    XML_file = xmlread(XML_file_addr);
    Info_KeyWords = ["BPM" 'BeatPerBar' 'BeatLen'...
        'EnterTimeAdjust' 'NotePreShow'...
        'LevelTime' 'BarAmount' 'BeginBarLen'... 
        'IsFourTrack' 'TrackCount' 'LevelPreTime'...
        'Title' 'Artist' 'FilePath'...
        'IndicatorResetPos' ];
    Info_KeyWords_cell = {'BPM' 'BeatPerBar' 'BeatLen'...
        'EnterTimeAdjust' 'NotePreShow'...
        'LevelTime' 'BarAmount' 'BeginBarLen'... 
        'IsFourTrack' 'TrackCount' 'LevelPreTime'...
        'Title' 'Artist' 'FilePath'...
        'IndicatorResetPos' };
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
    Info_Martix_cell = cell(1, size(Info_KeyWords, 2));
    for i = 1:max(size(Info_KeyWords))
        Select_Node = XML_file.getElementsByTagName(Info_KeyWords(1, i));
        if Select_Node.getLength ~= 1
            error('ERROR|%s_Info_Node Not Correct', Info_KeyWords(1, i));
        end
        Info_Martix_cell{1, i} = string(Select_Node.item(0).getTextContent);
    end
    
    Info_Martix_table = cell2table(Info_Martix_cell, 'VariableNames', Info_KeyWords_cell);
    Info_Martix_table.BgmId = regexp(Info_Martix_table.FilePath, '\d+', 'match');
    Note_Nodes = XML_file.getElementsByTagName('NoteInfo');
    Note_Nodes = Note_Nodes.item(0);
    Note_Nodes = Note_Nodes.getElementsByTagName('Note');

    Note_Attr_KeyWords = ["Bar" "Pos" "from_track"...
        "target_track" "note_type" "EndBar"...
        "EndPos" "end_track" "BeatPos"...
        "Type" "Track" "ID" "Son" "EndArea"];
    Note_Attr_KeyWords_cell = {'Bar' 'Pos' 'from_track'...
        'target_track' 'note_type' 'EndBar'...
        'EndPos' 'end_track' 'BeatPos'...
        'Type' 'Track' 'ID' 'Son' 'EndArea'};
    
    Not_Typ_id = find((Note_Attr_KeyWords == 'note_type') ==1);
    End_Bar_id = (Note_Attr_KeyWords == 'EndBar') ==1;
    End_Pos_id = (Note_Attr_KeyWords == 'EndPos') ==1;
    Str_Bar_id = (Note_Attr_KeyWords == 'Bar') ==1;
    Str_Pos_id = (Note_Attr_KeyWords == 'Pos') ==1;
    End_Tra_id = (Note_Attr_KeyWords == 'end_track') ==1;
    Fro_Tra_id = (Note_Attr_KeyWords == 'from_track') ==1;
    Note_Attr_number = max(size(Note_Attr_KeyWords));
    Note_Martix = cell(Note_Nodes.getLength, Note_Attr_number);
    note_available_count = 1;
    for i = 0:Note_Nodes.getLength - 1
        Note_Node = Note_Nodes.item(i);
        if ~Note_Node.hasAttribute('Bar')
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
    if ~isempty(find((Note_Martix_table.EndArea == "") == 0))
        Info_Martix_table.ModeType = "PinBall";
    elseif XML_file.getElementsByTagName('ScreenPos').getLength > 2
        Info_Martix_table.ModeType = "Bubble";
        Note_Martix_table.Pos = Note_Martix_table.BeatPos; 
        Note_Martix_table.note_type = Note_Martix_table.Type;
        Note_Martix_table.EndPos(Note_Martix_table.note_type == 0) = ...
            Note_Martix_table.Pos(Note_Martix_table.note_type == 0);
        Note_Martix_table.EndBar(Note_Martix_table.note_type == 0) = ...
            Note_Martix_table.Bar(Note_Martix_table.note_type == 0);
        
        Note_Martix_table.note_type = string(Note_Martix_table.note_type);
        Note_Martix_table.EndPos = str2double(Note_Martix_table.EndPos);
        Note_Martix_table.EndBar = str2double(Note_Martix_table.EndBar);
        Note_Martix_table.from_track(:) = "Null";
        Note_Martix_table.target_track = Note_Martix_table.from_track;
    else
        Info_Martix_table.ModeType = "Idol";
    end
    %Raw_data
    Map.Info = Info_Martix_table;
    Map.Notes = Note_Martix_table;
    clearvars -except Map;
    
    Note_Martix_table_out.Pos = (Map.Notes.Bar-1)*4*8 + Map.Notes.Pos/2;
    Note_Martix_table_out.EndPos = (Map.Notes.EndBar-1)*4*8 + Map.Notes.EndPos/2;
    Note_Martix_table_out.note_type = Map.Notes.note_type;
    Note_Martix_table_out.from_track = Map.Notes.from_track;
    Note_Martix_table_out.target_track = Map.Notes.target_track;
    
    file_save_name = sprintf('%s-%s-%s-%s.txt', Map.Info.BgmId,...
        Map.Info.EnterTimeAdjust, Map.Info.BPM,...
        Map.Info.Title);
    file = fopen("D:/" + string(file_save_name), 'w');

    for i = 1:size(Note_Martix_table_out.Pos, 1)
        fprintf(file, '%s\t%d\t%d\t%s\t%s\n', Note_Martix_table_out.note_type(i),...
            Note_Martix_table_out.Pos(i), Note_Martix_table_out.EndPos(i),...
            Note_Martix_table_out.from_track(i), Note_Martix_table_out.target_track(i));
    end
    fclose(file);
    status = 1;
end