% 定义ROI区域的多边形
A_polygon = [280, 360, 360, 280, 280; 0, 0, 280, 280, 0];
B_polygon = [360, 600, 560, 380, 360; 280, 420, 480, 350, 280];
C_polygon = [280, 380, 80, 45, 280; 280, 350, 480, 420, 280];

% 获取所有实验文件列表
files = dir('e*.txt');
numFiles = length(files);

% 初始化结果表格
results = table('Size', [numFiles, 4], ...
    'VariableTypes', {'string', 'double', 'double', 'double'}, ...
    'VariableNames', {'Experiment', 'totalEntriesNumber', 'spontaneousAlternationNumber', 'spontaneousAlternationPercent'});

% 循环处理每个文件
for i = 1:numFiles
    % 获取完整文件名
    filename = fullfile(files(i).folder, files(i).name);
    
    % 获取实验名称（不含扩展名）
    [~, name, ~] = fileparts(filename);
    
    % 读取数据
    try
        data = readmatrix(filename);
    catch ME
        warning(['错误读取文件 ' filename ': ' ME.message]);
        continue;
    end
    
    % 检查数据完整性
    if size(data, 2) ~= 2
        warning(['文件 ' filename ' 没有两列数据。跳过。']);
        continue;
    end
    
    x = data(:,1);
    y = data(:,2);
    
    % 绘制轨迹图
    fig = figure;
    plot(x, y, 'r-');
    hold on;
    % 设置图形属性
    title(' ');
    xlabel(' ');
    ylabel(' ');
    grid off;
    axis off;
    % 设置背景为透明
    set(gca, 'Color', 'none');
    set(gcf, 'Color', 'none');
    % 保存图形
    tifname = [name '.tif'];
    saveas(fig, tifname);
    close(fig);
    
    % 初始化记录序列
    entrySequence = {};
    previousROI = '';
    
    % 遍历每一帧数据
    for j = 1:length(x)
        if inpolygon(x(j), y(j), A_polygon(1,:), A_polygon(2,:))
            currentROI = 'A';
        elseif inpolygon(x(j), y(j), B_polygon(1,:), B_polygon(2,:))
            currentROI = 'B';
        elseif inpolygon(x(j), y(j), C_polygon(1,:), C_polygon(2,:))
            currentROI = 'C';
        else
            currentROI = 'Z';
        end
        if ~strcmp(currentROI, previousROI) && ~strcmp(currentROI, 'Z')
            entrySequence{end+1} = currentROI;
        end
        previousROI = currentROI;
    end
    
    % 统计进入次数
    totalEntriesNumber = length(entrySequence);
    
    % 统计自发交替行为
    spontaneousAlternationNumber = 0;
    for j = 2:(totalEntriesNumber-1)
        if ~strcmp(entrySequence{j-1}, entrySequence{j+1})
            spontaneousAlternationNumber = spontaneousAlternationNumber + 1;
        end
    end
    
    % 计算自发交替率
    if totalEntriesNumber >= 3
        spontaneousAlternationPercent = spontaneousAlternationNumber / (totalEntriesNumber - 2) * 100;
    else
        spontaneousAlternationPercent = 0;
    end
    
    % 将结果添加到表格中
    results(i, :) = {string(name), totalEntriesNumber, spontaneousAlternationNumber, spontaneousAlternationPercent};
end

% 将结果表格写入Excel文件
writetable(results, 'results.xlsx');