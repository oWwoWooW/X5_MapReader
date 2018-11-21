Folder = 'C:\Out';
fileFolder=fullfile(Folder);
dirOutput=dir(fullfile(fileFolder,'*.txt'));
for i = 624:size(dirOutput, 1)
    singal = dirOutput(i);
    fileAddr = sprintf('%s\\%s', singal.folder, singal.name);
    Map_out = bytesTxt2Mat(fileAddr);
    if Process(Map_out) == 1
        fprintf('Status | Success %d/%d\n', i, size(dirOutput, 1));
    else
        fprintf('Status | Error %s\n', i, fileAddr);
    end
end