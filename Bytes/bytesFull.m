Folder = 'C:\Out1';
fileFolder=fullfile(Folder);
dirOutput=dir(fullfile(fileFolder,'*.txt'));
for i = 1:size(dirOutput, 1)
    singal = dirOutput(i);
    fileAddr = sprintf('%s\\%s', singal.folder, singal.name);
    if contains(fileAddr, 'log.txt')
        continue;
    elseif contains(fileAddr, 'CB.txt')
        continue;
    end
    Map_out = bytesTxt2Mat(fileAddr);
    if SProcess(Map_out) == 1      %若使用时间-爆气图则调用Process(Map_out)
        fprintf('Status | Success %d/%d\n', i, size(dirOutput, 1));
    else
        fprintf('Status | Error %s\n', i, fileAddr);
    end
end