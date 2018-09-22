%%%4.19更新后爆气时间基本固定%%%
%5.18Pos改为180
function a = UPDATE_4_19_PinBall(addr)
a = 0;
%
% addr = "D:\Decode_File\PinBall\300008-309-90-Faded.txt";
Score_Note_shot = 2600;
Score_Note_Long = 780;
Score_Note_seri = 2600;
Score_Note_slip = 2600;
Score_Note_Slip = Score_Note_slip * 2;
tic
info = regexp(addr, '\d+', 'match');
titleq = regexp(addr, [info{2} '.+.txt'], 'match');
bpm = str2double(info{4});
et = str2double(info{3});
Stay_Time = 180/8*60/bpm;
fprintf(['BPM:' num2str(bpm) '//ET:' num2str(et) '\n'])
data2 = readtable(addr, 'Format', '%s%f%f', 'Delimiter', '\t', 'ReadVariableNames', true);
% p = GetData(data2, bpm, et);
resort = sortrows(data2,1);

max_pos = max(data2{:, 3});
Total_Score_Long = zeros(max_pos, 2); 
Total_Score_Long(:, 2) = [0:max_pos-1]./8*60/bpm+et/1000;
Total_Score_Slip = Total_Score_Long;
Total_Score_Shot = Total_Score_Long;
Total_Score_Seri = Total_Score_Long;
Total_Score_Mix = Total_Score_Long;
for i = 1:size(data2, 1)    
    if strcmp(data2{i, 1}, 'slip')
        Total_Score_Slip(data2{i, 2}, 1) = Total_Score_Slip(data2{i, 2}, 1) + Score_Note_slip;
    elseif strcmp(data2{i, 1}, 'shot')
        Total_Score_Shot(data2{i, 2}, 1) = Total_Score_Shot(data2{i, 2}, 1) + Score_Note_shot;
    elseif strcmp(data2{i, 1}, 'Slip')
        Total_Score_Slip(data2{i, 2}, 1) = Total_Score_Slip(data2{i, 2}, 1) + Score_Note_Slip;   %二次两倍
    elseif strcmp(data2{i, 1}, 'seri')
        Total_Score_Seri(data2{i, 2}, 1) = Total_Score_Seri(data2{i, 2}, 1) + Score_Note_seri;  
    elseif strcmp(data2{i, 1}, 'long')
        Total_Score_Long(data2{i, 2}:2:data2{i, 3}, 1) = Total_Score_Long(data2{i, 2}:2:data2{i, 3}, 1) + Score_Note_Long;
    else
        error('Note Type Error')
    end
end
Total_Score_Mix(:, 1) = Total_Score_Long(:, 1) + Total_Score_Slip(:, 1) + Total_Score_Shot(:, 1) + Total_Score_Seri(:, 1);	%各类分数相加得出总分   

time = floor(max(Total_Score_Long(:, 2))) + 1;
time_hist_score_long = zeros(time, 1);
time_hist_score_shot = zeros(time, 1);
time_hist_score_slip = zeros(time, 1);
time_hist_score_seri = zeros(time, 1);
time_hist_score_mix = zeros(time, 1);
for i = 1:size(Total_Score_Long, 1)
    time_hist_score_long(floor(Total_Score_Long(i, 2))+1) = time_hist_score_long(floor(Total_Score_Long(i, 2))+1) + Total_Score_Long(i, 1);
    time_hist_score_shot(floor(Total_Score_Shot(i, 2))+1) = time_hist_score_shot(floor(Total_Score_Shot(i, 2))+1) + Total_Score_Shot(i, 1);
    time_hist_score_slip(floor(Total_Score_Slip(i, 2))+1) = time_hist_score_slip(floor(Total_Score_Slip(i, 2))+1) + Total_Score_Slip(i, 1);
    time_hist_score_seri(floor(Total_Score_Seri(i, 2))+1) = time_hist_score_seri(floor(Total_Score_Seri(i, 2))+1) + Total_Score_Seri(i, 1);
    time_hist_score_mix(floor(Total_Score_Mix(i, 2))+1) = time_hist_score_mix(floor(Total_Score_Mix(i, 2))+1) + Total_Score_Mix(i, 1);
end
time_hist_score_dist = [time_hist_score_long';time_hist_score_shot';time_hist_score_slip';time_hist_score_seri']; %转换为图表数据格式

figure('Position', [0 0 1920 1080], 'Visible', 'off');
subplot(2,1,1)  %每秒note
fg = bar(0:time-1, time_hist_score_dist', 'stacked', 'EdgeColor', 'none');
set(fg(1),'facecolor','r')
set(fg(2),'facecolor',[0.5 1 0.5])
set(fg(3),'facecolor',[1 0.5 0.5])
set(fg(4),'facecolor',[0.5 0.5 1])
axis([0 time-1 0 max(time_hist_score_mix)+2000])
legend('Long','Short', 'Slip', 'Seri')
title(titleq{1});

time_stack_score = zeros(time, 3);  %|Time_Start|Time_End|Score|
for i = 1:time
    %a = Find_Keep_Time(i-1, total_long_table_with_symbol, Stay_Time);
    %对应4.19更新
    time_stack_score(i, 1) = i - 1;
    time_stack_score(i, 2) = i - 1 + Stay_Time;
end

for i = 1:size(time_stack_score, 1)
    score_buff = 0;
    for j = 1:size(Total_Score_Mix, 1)
        if Total_Score_Mix(j, 2) < time_stack_score(i, 1)
            continue;
        elseif Total_Score_Mix(j, 2) < time_stack_score(i, 2)
            score_buff = score_buff + Total_Score_Mix(j, 1);
            if j~= size(Total_Score_Mix, 1)
                continue
            else
                time_stack_score(i, 3) = score_buff;
            end
        else
            time_stack_score(i, 3) = score_buff;
            break;
        end
    end
    %time_stack_score(i, 3) = score_buff;
end

subplot(2, 1, 2)
bar(time_stack_score(:, 1), time_stack_score(:, 3), 'FaceColor', [0.3 1 0.7], 'EdgeColor',[0.5 0.3 0.7])
axis([0 time-1 0 max(time_stack_score(:, 3))+2000])
title({'^P^i^n^B^a^l^l Basic Score' ;['KEEP TIME: ' num2str(Stay_Time)]})
[pks,locs]=findpeaks(time_stack_score(:, 3),'minpeakdistance',4);
grid on;
text(locs-1.5,pks,'o','color','r', 'FontSize',10)
for i = 1:size(locs, 1)
    text(locs(i)-0.5,pks(i),['[' num2str(locs(i)-1) ',' num2str(pks(i)) ']'],'color',[0.5 0.3 0.5], 'FontSize',8)
end
grid off
toc
saveas(gcf,['F:\0518\Out\' titleq{1} '.jpg']);   
%函数结构用
a = 1;
return
end
%