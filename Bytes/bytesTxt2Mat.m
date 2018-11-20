clear all
Folder = 'C:\Out';
fileFolder=fullfile(Folder);
dirOutput=dir(fullfile(fileFolder,'*.txt'));
singal = dirOutput(70);
name = sprintf('%s\\%s', singal.folder, singal.name);
fileAddr = name;
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
Notes = table;
Notes.Pos = Data{1, 2};
Notes.EndPos = Data{1, 3};
Notes.note_type = Data{1, 1};
Map_out.Notes = Notes;
Map_out.Info = Info;