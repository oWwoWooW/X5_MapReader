% clear all;
% load('Bubble.mat');
function Result = Process(Map_out)
    Result = 0;
    % 输入Idol的Map_out矩阵
    %% 定义区
    % Idol
    Score_Note_short = 2600;
    Score_Note_long = 780;
    Score_Note_slip = 2600;
    % Bubble
    Score_Note_0_yellow = 2600;
    Score_Note_1_green = Score_Note_0_yellow * 0.3;
    Score_Note_2_blue = 2600;
    % Pinball
    Score_Note_PinballSingle = 2600;
    Score_Note_PinballLong = 780;
    Score_Note_PinballSeries = 2600;
    Score_Note_PinballSlip = 2600;
    Score_Note_PinballSlipX2 = Score_Note_PinballSlip * 2;
    %
    bpm = str2double(Map_out.Info.BPM);
    et = str2double(Map_out.Info.EnterTimeAdjust);
    BuffPos = 160;
    Stay_Time = BuffPos/8*60/bpm;
    %% 创建Pos-Score表
    max_pos = max([Map_out.Notes.Pos' Map_out.Notes.EndPos']);
    Score = table;
    % 每个Pos一行
    Total_Score_Buf = zeros(max_pos, 1);
    if Map_out.Info.ModeType == "Idol"
        Score.long = Total_Score_Buf;
        Score.short = Score.long;
        Score.slip = Score.long;
    elseif Map_out.Info.ModeType == "Pinball"
        Score.PinballSingle = Total_Score_Buf;
        Score.PinballLong = Score.PinballSingle;
        Score.PinballSeries = Score.PinballSingle;
        Score.PinballSlip = Score.PinballSingle;
        Score.PinballSlipX2 = Score.PinballSingle;
    elseif Map_out.Info.ModeType == "Bubble"
        Score.type_0_yellow = Total_Score_Buf;
        Score.type_1_green = Score.type_0_yellow;
        Score.type_2_blue = Score.type_0_yellow;
    end
    Score.time = ([0:max_pos-1]./8*60/bpm+et/1000)';
    Score.Mix = Total_Score_Buf;
    % 遍历Note 分配Score到Pos
    % Long、Green、Blue各版本有修改
    for i = 1:max(size(Map_out.Notes.Pos))   
        Note_type = string(Map_out.Notes.note_type(i));
        Note_Start_Pos = Map_out.Notes.Pos(i);
        Note_End_Pos = Map_out.Notes.EndPos(i);
        % Idol 每个Pos加上分数
        if Map_out.Info.ModeType == "Idol"
            if Note_type == "short" || Note_type == "shot"
                Score.short(Note_Start_Pos) = Score.short(Note_Start_Pos) + Score_Note_short;
            elseif Note_type == "slip"
                Score.slip(Note_Start_Pos) = Score.slip(Note_Start_Pos) + Score_Note_slip;
            elseif Note_type == "long"
                Score.long(Note_Start_Pos:2:Note_End_Pos) = Score.long(Note_Start_Pos:2:Note_End_Pos) + Score_Note_long;
            else
                error('Note Type Error');
            end
        elseif Map_out.Info.ModeType == "Pinball"
            if Note_type == "PinballSingle"
                Score.PinballSingle(Note_Start_Pos) = Score.PinballSingle(Note_Start_Pos) + Score_Note_PinballSingle;
            elseif Note_type == "PinballLong"
                Score.PinballLong(Note_Start_Pos:2:Note_End_Pos) = Score.PinballLong(Note_Start_Pos:2:Note_End_Pos) + Score_Note_PinballLong;
            elseif Note_type == "PinballSeries" || Note_type == "PinballSeriesX2"
                Score.PinballSeries(Note_Start_Pos) = Score.PinballSeries(Note_Start_Pos) + Score_Note_PinballSeries;
            elseif Note_type == "PinballSlip"
                Score.PinballSlip(Note_Start_Pos) = Score.PinballSlip(Note_Start_Pos) + Score_Note_PinballSlip;
            elseif Note_type == "PinballSlipX2"
                Score.PinballSlipX2(Note_Start_Pos) = Score.PinballSlipX2(Note_Start_Pos) + Score_Note_PinballSlipX2;
            else
                error('Note Type Error:%s', Note_type);
            end
        else
            if Note_type == "0"
                Score.type_0_yellow(Note_Start_Pos) = Score.type_0_yellow(Note_Start_Pos) + Score_Note_0_yellow;
            elseif Note_type == "1"
                Score.type_1_green(Note_Start_Pos:4:Note_End_Pos) = Score.type_1_green(Note_Start_Pos:4:Note_End_Pos) + Score_Note_1_green;
            elseif Note_type == "2"
                Score.type_2_blue(Note_Start_Pos:4:Note_End_Pos) = Score.type_2_blue(Note_Start_Pos:4:Note_End_Pos) + Score_Note_2_blue;
            else
                error('Note Type Error');
            end
        end
    end
    if Map_out.Info.ModeType == "Idol"
        Score.Mix = Score.short + Score.slip + Score.long;
    elseif Map_out.Info.ModeType == "Pinball"
        Score.Mix = Score.PinballSingle + Score.PinballLong + Score.PinballSeries + Score.PinballSlip + Score.PinballSlipX2;
    else
        Score.Mix = Score.type_0_yellow + Score.type_1_green + Score.type_2_blue;
    end
    %% 建立time-Score表
    X_Label_Time = floor(max(Score.time)) + 1;
    % Time(1)对应[0,0+T]积分
    Time_table = table;
    Time_table.start_second = [0:X_Label_Time-1]';
    Time_table.end_second = Time_table.start_second + Stay_Time;
    Time_table.start_pos = zeros(size(Time_table.start_second));
    Time_table.end_pos = Time_table.start_pos;
    % 分配空间
    if Map_out.Info.ModeType == "Idol"
        % Idol
        Time_table.short = zeros(size(Time_table.start_second));
        Time_table.long = Time_table.short;
        Time_table.slip = Time_table.short;
    elseif Map_out.Info.ModeType == "Pinball"
        Time_table.PinballSingle = zeros(size(Time_table.start_second));
        Time_table.PinballLong = Time_table.PinballSingle;
        Time_table.PinballSeries = Time_table.PinballSingle;
        Time_table.PinballSlip = Time_table.PinballSingle;
        Time_table.PinballSlipX2 = Time_table.PinballSingle;
    else
        Time_table.type_0_yellow = zeros(size(Time_table.start_second));
        Time_table.type_1_green = Time_table.type_0_yellow;
        Time_table.type_2_blue = Time_table.type_0_yellow;
    end
    for i = 1 : X_Label_Time
        % 找到对应时间段Pos上下界
        Time_table.start_pos(i) = find(Score.time >= Time_table.start_second(i), 1, 'first');
        % 防止EndPos时还未开始
        if ~isempty(find(Time_table.end_second(i) > Score.time, 1))
            Time_table.end_pos(i) = find(Time_table.end_second(i) > Score.time, 1, 'last' );
        else
            Time_table.end_pos(i) = Time_table.end_second(1)*bpm*8/60;
        end
        
        % Idol
        if Map_out.Info.ModeType == "Idol"
            Time_table.short(i) = sum(Score.short(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.long(i) = sum(Score.long(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.slip(i) = sum(Score.slip(Time_table.start_pos(i) : Time_table.end_pos(i)));
        elseif Map_out.Info.ModeType == "Pinball"
            Time_table.PinballSingle(i) = sum(Score.PinballSingle(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.PinballLong(i) = sum(Score.PinballLong(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.PinballSeries(i) = sum(Score.PinballSeries(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.PinballSlip(i) = sum(Score.PinballSlip(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.PinballSlipX2(i) = sum(Score.PinballSlipX2(Time_table.start_pos(i) : Time_table.end_pos(i)));
        else
            Time_table.type_0_yellow(i) = sum(Score.type_0_yellow(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.type_1_green(i) = sum(Score.type_1_green(Time_table.start_pos(i) : Time_table.end_pos(i)));
            Time_table.type_2_blue(i) = sum(Score.type_2_blue(Time_table.start_pos(i) : Time_table.end_pos(i)));
        end
    end
    % Idol
    if Map_out.Info.ModeType == "Idol"
        Time_table.Mix = Time_table.short + Time_table.long + Time_table.slip;
    elseif Map_out.Info.ModeType == "Pinball"
        Time_table.Mix = Time_table.PinballSingle + Time_table.PinballLong + Time_table.PinballSeries + Time_table.PinballSlip + Time_table.PinballSlipX2;
    else
        Time_table.Mix = Time_table.type_0_yellow + Time_table.type_1_green + Time_table.type_2_blue;
    end

    %% 绘图 
    figure('Position', [0 0 1920 1080], 'Visible', 'off');
    if Map_out.Info.ModeType == "Idol"
        Bar_hist = [Time_table.short';Time_table.long';Time_table.slip';]; %转换为图表数据格式

    elseif Map_out.Info.ModeType == "Pinball"  
        Bar_hist = [Time_table.PinballSingle';Time_table.PinballLong';Time_table.PinballSeries';(Time_table.PinballSlip + Time_table.PinballSlipX2)'];
    else
        Bar_hist = [Time_table.type_0_yellow';Time_table.type_1_green';Time_table.type_2_blue'];
    end
    figure_bar = bar(Time_table.start_second, Bar_hist', 'stacked', 'EdgeColor', 'none');
    axis([-1 max(Time_table.start_second+1) 0 max(Time_table.Mix)+2000]);
    if Map_out.Info.ModeType == "Idol"
        title({'^I^d^o^l '+Map_out.Info.Title ;['KEEP TIME: ' num2str(Stay_Time)]});
        set(figure_bar(2),'facecolor',[0.5 1 0.5]);set(figure_bar(1),'facecolor',[1 0.5 0.5]);set(figure_bar(3),'facecolor',[0.5 0.5 1]);
        legend('Short','Long', 'Slip')
    elseif Map_out.Info.ModeType == "Pinball"
        title({'^P^i^n^B^a^l^l '+Map_out.Info.Title ;['KEEP TIME: ' num2str(Stay_Time)]});
        set(figure_bar(1),'facecolor','r');set(figure_bar(2),'facecolor',[0.5 1 0.5]);set(figure_bar(3),'facecolor',[1 0.5 0.5]);set(figure_bar(4),'facecolor',[0.5 0.5 1]);
        legend('Single','Long', 'Series', 'Slip')
    else
        title({'^B^u^b^b^l^e '+Map_out.Info.Title ;['KEEP TIME: ' num2str(Stay_Time)]});
        set(figure_bar(1),'facecolor',[225/255 167/255 57/255]);set(figure_bar(1),'facecolor',[0.5 1 0.5]);set(figure_bar(3),'facecolor',[0.5 0.5 1]);
        legend('Yellow','Green', 'Blue')
    end
    %% 极值
    [pks,locs]=findpeaks(Time_table.Mix,'minpeakdistance',4);
    grid on;
    text(locs-1.5,pks,'o','color','r', 'FontSize',10)
    for i = 1:size(locs, 1)
        text(locs(i)-0.5,pks(i),['[' num2str(locs(i)-1) ',' num2str(pks(i)) ']'],'color',[0.5 0.3 0.5], 'FontSize',8)
    end
    grid off
    %% SAVE
    buf_BgmId = regexprep(Map_out.Info.BgmId, '[\\/:*?"<>|]', '');
    buf_title = regexprep(Map_out.Info.Title, '[\\/:*?"<>|]', '');
    buf = sprintf('F:\\OutFolder\\%s-%s-%s.jpg', Map_out.Info.ModeType, buf_BgmId, buf_title);
    saveas(gcf,buf);
    fprintf('Save To:\t%s\n', buf);
    Result = 1;
end