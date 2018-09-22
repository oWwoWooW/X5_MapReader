clear all
Folder = 'D:\X5\';
fileFolder=fullfile(Folder);
dirOutput=dir(fullfile(fileFolder,'*.xml'));
file_counter = max(size(dirOutput));
fileNames={dirOutput.name}';
file_list = Folder + string(fileNames);
for i = 1:file_counter
    [Map, status] = Read_Xml(char(file_list(i)));
    if status == 1
        statue = Process(Map);
    end
end