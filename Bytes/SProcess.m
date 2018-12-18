% clear all;
% load('Bubble.mat');
%18-12-16检查发现SP加成实为11%
%爆气分数为原1.5x
%爆气加成下为原2.7x
function Result = SProcess(Map_out)
    Result = 0;
    % 输入Idol的Map_out矩阵
    %% 定义区
    % Idol
    Score_Note_short = 2600;                        %Check
    Score_Note_long = 780;                          %Check
    Score_Note_slip = 2600;                         %Check
    % Bubble
    Score_Note_0_yellow = 2600;                     %Check
    Score_Note_1_green = Score_Note_0_yellow * 0.3; %Check
    Score_Note_2_blue = 2600;                       %Check
    % Pinball
    Score_Note_PinballSingle = 2600;                %Check
    Score_Note_PinballLong = 780;                   %无压线
    Score_Note_PinballSeries = 2600;                %Check
    Score_Note_PinballSlip = 2600;                  %Check
    Score_Note_PinballSlipX2 = ...
        Score_Note_PinballSlip * 2;                 %Check
    %
    bpm = str2double(Map_out.Info.BPM);
    et = str2double(Map_out.Info.EnterTimeAdjust);
    BuffPos = 160;                                  %Check
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
    %建立Note数量表
    Note_Pos = Score; Note_Pos.time = [];
    Note_Pos.NoteAmountMix = Note_Pos.Mix; Note_Pos.Mix = [];
    
    % 遍历Note 分配Score到Pos
    % Long、Green、Blue各版本有修改
    for i = 1:max(size(Map_out.Notes.Pos))   
        Note_type = string(Map_out.Notes.note_type(i));
        Note_Start_Pos = Map_out.Notes.Pos(i);
        Note_End_Pos = Map_out.Notes.EndPos(i);
        % Idol 每个Pos加上分数和Note数量
        if Map_out.Info.ModeType == "Idol"
            if Note_type == "short" || Note_type == "shot"
                Score.short(Note_Start_Pos) = Score.short(Note_Start_Pos) + Score_Note_short;
                Note_Pos.short(Note_Start_Pos) = Note_Pos.short(Note_Start_Pos) + 1;
            elseif Note_type == "slip"
                Score.slip(Note_Start_Pos) = Score.slip(Note_Start_Pos) + Score_Note_slip;
                Note_Pos.slip(Note_Start_Pos) = Note_Pos.slip(Note_Start_Pos) + 1;
            elseif Note_type == "long"
                Score.long(Note_Start_Pos:2:Note_End_Pos) = Score.long(Note_Start_Pos:2:Note_End_Pos) + Score_Note_long;
                Note_Pos.long(Note_Start_Pos:2:Note_End_Pos) = Note_Pos.long(Note_Start_Pos:2:Note_End_Pos) + 1;
            else
                error('Note Type Error');
            end
        elseif Map_out.Info.ModeType == "Pinball"
            if Note_type == "PinballSingle"            
                Score.PinballSingle(Note_Start_Pos) = Score.PinballSingle(Note_Start_Pos) + Score_Note_PinballSingle;
                Note_Pos.PinballSingle(Note_Start_Pos) = Note_Pos.PinballSingle(Note_Start_Pos) + 1;
            elseif Note_type == "PinballLong"
                Score.PinballLong(Note_Start_Pos:2:Note_End_Pos) = Score.PinballLong(Note_Start_Pos:2:Note_End_Pos) + Score_Note_PinballLong;
                Note_Pos.PinballLong(Note_Start_Pos:2:Note_End_Pos) = Note_Pos.PinballLong(Note_Start_Pos:2:Note_End_Pos) + 1;
            elseif Note_type == "PinballSeries" || Note_type == "PinballSeriesX2"
                Score.PinballSeries(Note_Start_Pos) = Score.PinballSeries(Note_Start_Pos) + Score_Note_PinballSeries;
                Note_Pos.PinballSeries(Note_Start_Pos) = Note_Pos.PinballSeries(Note_Start_Pos) + 1;
            elseif Note_type == "PinballSlip"
                Score.PinballSlip(Note_Start_Pos) = Score.PinballSlip(Note_Start_Pos) + Score_Note_PinballSlip;
                Note_Pos.PinballSlip(Note_Start_Pos) =Note_Pos.PinballSlip(Note_Start_Pos) + 1;
            elseif Note_type == "PinballSlipX2"
                Score.PinballSlipX2(Note_Start_Pos) = Score.PinballSlipX2(Note_Start_Pos) + Score_Note_PinballSlipX2;
                Note_Pos.PinballSlipX2(Note_Start_Pos) = Note_Pos.PinballSlipX2(Note_Start_Pos) + 1;
            else
                error('Note Type Error:%s', Note_type);
            end
        else
            if Note_type == "0"
                Score.type_0_yellow(Note_Start_Pos) = Score.type_0_yellow(Note_Start_Pos) + Score_Note_0_yellow;
                Note_Pos.type_0_yellow(Note_Start_Pos) = Note_Pos.type_0_yellow(Note_Start_Pos) + 1;
            elseif Note_type == "1"
                Score.type_1_green(Note_Start_Pos:4:Note_End_Pos) = Score.type_1_green(Note_Start_Pos:4:Note_End_Pos) + Score_Note_1_green;
                Note_Pos.type_1_green(Note_Start_Pos:4:Note_End_Pos) =Note_Pos.type_1_green(Note_Start_Pos:4:Note_End_Pos) + 1;
            elseif Note_type == "2"
                Score.type_2_blue(Note_Start_Pos:4:Note_End_Pos) = Score.type_2_blue(Note_Start_Pos:4:Note_End_Pos) + Score_Note_2_blue;
                Note_Pos.type_2_blue(Note_Start_Pos:4:Note_End_Pos) =Note_Pos.type_2_blue(Note_Start_Pos:4:Note_End_Pos) + 1;
            else
                error('Note Type Error');
            end
        end
    end
    if Map_out.Info.ModeType == "Idol"
        Score.Mix = Score.short + Score.slip + Score.long;
        Note_Pos.NoteAmountMix = Note_Pos.short + Note_Pos.slip + Note_Pos.long;
    elseif Map_out.Info.ModeType == "Pinball"
        Score.Mix = Score.PinballSingle+Score.PinballLong+...
            Score.PinballSeries+Score.PinballSlip+Score.PinballSlipX2;
        Note_Pos.NoteAmountMix = Note_Pos.PinballSingle+...
            Note_Pos.PinballLong+Note_Pos.PinballSeries+...
            Note_Pos.PinballSlip+Note_Pos.PinballSlipX2;
    else
        Score.Mix = Score.type_0_yellow + Score.type_1_green + Score.type_2_blue;
        Note_Pos.NoteAmountMix = Note_Pos.type_0_yellow+...
            Note_Pos.type_1_green+Note_Pos.type_2_blue;
    end
    
    %% Pos分数表
    Note_Pos.TotalNoteAmount = Note_Pos.NoteAmountMix;
    PosTable = table;
    PosTable.TargetTime = [1:(height(Score))]' + BuffPos-1;
    PosTable.TargetTime(PosTable.TargetTime>height(Score)) = height(Score);
    PosTable.Mix = zeros(height(PosTable), 1);

    %For循环内快速算法
    LU = cumsum(Score.Mix);
    LU2 = LU(BuffPos:end);
    LU = [0; LU(1:end-1)];
    LU2 = [LU2; repelem(LU2(end), length(LU) - length(LU2))'];
    CC = LU2-LU;
    PosTable.Mix = CC;
    Note_Pos.TotalNoteAmount = cumsum(Note_Pos.NoteAmountMix);

%     for i = 1:height(PosTable)
%         PosTable.Mix(i) = sum(Score.Mix(i:PosTable.TargetTime(i)));
%         if i == 1 
%             continue; 
%         else
%             Note_Pos.TotalNoteAmount(i) = Note_Pos.TotalNoteAmount(i) + Note_Pos.TotalNoteAmount(i-1);
%         end
%     end

    Score.TotalNoteAmount = Note_Pos.TotalNoteAmount;
    noteScoreTable = table;
    index = find(Note_Pos.NoteAmountMix ~= 0);
    noteScoreTable.NoteNum = Note_Pos.TotalNoteAmount(index);
    noteScoreTable.NoteNum = [0; noteScoreTable.NoteNum(1:height(noteScoreTable)-1)];
	noteScoreTable.Score  = PosTable.Mix(index);
       
    %% 绘图 CB直方图
    shape = figure('Position', [0 0 1920 1080], 'Visible', 'off');
    resortScore = sortrows(noteScoreTable,2, 'descend');
    
    bar(noteScoreTable.NoteNum, noteScoreTable.Score, 'EdgeColor', 'none', 'FaceColor', [0.35 0.6 0.85])
    ax = gca;
    ax.XTickLabelMode = 'manual';
    ax.XTick = min(noteScoreTable.NoteNum(1)):25:max(noteScoreTable.NoteNum(end));
    ax.XTickLabel = min(noteScoreTable.NoteNum(1)):25:max(noteScoreTable.NoteNum(end));
    axis([0 max(ax.XTick) (min(noteScoreTable.Score)-max(noteScoreTable.Score))/200 max(noteScoreTable.Score)]);
    axis([0 max(ax.XTick) 0 max(noteScoreTable.Score)]);

    textBuf = "";
    for i = 1:min(height(resortScore), 15)
        textBuf = textBuf + sprintf('%s\t%s\t%d\t%d\n', regexprep(Map_out.Info.Title, '[\\/:*?"<>|]', ''), Map_out.Info.ModeType, resortScore.NoteNum(i), resortScore.Score(i));
        text(35*(i-1), ax.YTick(end), int2str(resortScore.NoteNum(i)), 'color', 'r', 'FontSize', 20);
    end
    fid = fopen('C:\Out1\CB.txt', 'a+');                                                             %爆气点输出文件
    fprintf(fid, textBuf);
    fclose(fid);
    title(sprintf('连击-爆气直方图\n%s-%s\n爆气时长: %s', Map_out.Info.ModeType, Map_out.Info.Title, num2str(Stay_Time)));
    %% SAVE
    buf_BgmId = regexprep(Map_out.Info.BgmId, '[\\/:*?"<>|]', '');
    buf_title = regexprep(Map_out.Info.Title, '[\\/:*?"<>|]', '');
    buf = sprintf('C:\\Out1\\CB-%s-%s-%s.jpg', Map_out.Info.ModeType, buf_BgmId, buf_title);         %图片路径
    saveas(shape,buf);
    fprintf('Save To:\t%s\n', buf);
    close(shape);
    Result = 1;
end