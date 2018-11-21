function Map_out = bytesTxt2Mat(fileAddr)
    fileId = fopen(fileAddr, 'r', 'n', 'UTF-8');
    Varnumber = 14;
    data = textscan(fileId,'%s', Varnumber, 'delimiter', '\t');
    data = data{1, 1};
    Varname = cell(1, max(size(data)));
    Value = Varname;
    for i = 1:max(size(data))
        a = regexp(data{i}, ':', 'split');
        Varname{1, i} = a{1, 1};
        Value{1, i} = string(a{1, 2});
    end
    Info = cell2table(Value, 'VariableNames', Varname);
    Data = textscan(fileId,'%s\t%d\t%d');
    fclose(fileId);
    Notes = table;
    Notes.Pos = Data{1, 2};
    Notes.EndPos = Data{1, 3};
    Notes.note_type = Data{1, 1};
    if isempty(Notes)
        throw(MException('bytesRead:NoteListError', 'Status | Error NoteList Is Empty %s', fileAddr));
    end
    Map_out.Notes = Notes;
    Map_out.Info = Info;
   
end