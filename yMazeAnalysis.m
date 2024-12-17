clear; close all;

% 定义文件名的各个部分
prefix = 'e1'; % 文件名前缀
suffix1 = '.txt'; % 文件后缀
suffix2 = '.xlsx'; % 文件后缀
suffix3 = '.tif'; % 文件后缀

% 指定文件路径
filename = [prefix suffix1]; % 文件名

% 指定导出的Excel文件名
excel_filename = [prefix suffix2]; % 你可以根据需要修改这个文件名

% 定义图片名变量
tifname = [prefix suffix3];

% 定义ROI区域的多边形
A_polygon = [280, 360, 360, 280, 280; 0, 0, 280, 280, 0];
B_polygon = [360, 600, 560, 380, 360; 280, 420, 480, 350, 280];
C_polygon = [280, 380, 80, 45, 280; 280, 350, 480, 420, 280];

% 尝试使用 readmatrix 读取数据
try
    data = readmatrix(filename);
catch ME
    disp('Error reading the file with readmatrix:');
    disp(ME.message);
    % 如果 readmatrix 失败，尝试其他方法，比如 textscan
    fid = fopen(filename, 'r');
    if fid == -1
        error('File cannot be opened.');
    end
    % 读取两列数据
    data = textscan(fid, '%f%f', 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    % 将 cell 转换为 matrix
    data = cell2mat(data);
    fclose(fid);
end

% 检查数据维度
if size(data,2) ~= 2
    error('Data must have two columns.');
end

x = data(:,1);
y = data(:,2);

% 绘制轨迹图
fig = figure; % 创建一个新的图形窗口并获取其句柄
plot(x, y, 'r-'); % 绘制红色线图，'r-'表示红色实线
hold on; % 保持当前图形，以便添加更多元素

% 设置图形属性
title(' '); % 移除标题
xlabel(' '); % 移除X轴标签
ylabel(' '); % 移除Y轴标签
grid off; % 关闭网格
axis off; % 关闭坐标轴

% 设置背景为透明
set(gca, 'Color', 'none'); % 设置当前坐标轴的背景为透明
set(gcf, 'Color', 'none'); % 设置图形窗口的背景为透明

% 保存图形
saveas(fig, tifname);
close(fig); % 关闭图形窗口

% 初始化记录序列
entrySequence = {};

% 初始化previousROI
previousROI = '';

% 遍历每一帧数据
for i = 1:length(x)
    % 判断当前点在哪个ROI
    if inpolygon(x(i), y(i), A_polygon(1,:), A_polygon(2,:))
        currentROI = 'A';
    elseif inpolygon(x(i), y(i), B_polygon(1,:), B_polygon(2,:))
        currentROI = 'B';
    elseif inpolygon(x(i), y(i), C_polygon(1,:), C_polygon(2,:))
        currentROI = 'C';
    else
        currentROI = 'Z'; % 忽略Z区域
    end
    
    % 如果当前ROI与previousROI不同，并且不是Z，则记录
    if ~strcmp(currentROI, previousROI) && ~strcmp(currentROI, 'Z')
        entrySequence{end+1} = currentROI;
    end
    
    % 更新previousROI
    previousROI = currentROI;
end

% 统计进入次数
totalEntriesNumber = length(entrySequence);

% 统计自发交替行为
spontaneousAlternationNumber = 0;
for i = 2:(totalEntriesNumber-1)
    if ~strcmp(entrySequence{i-1}, entrySequence{i+1})
        spontaneousAlternationNumber = spontaneousAlternationNumber + 1;
    end
end

% 计算自发交替率
if totalEntriesNumber >= 3
    spontaneousAlternationPercent = spontaneousAlternationNumber / (totalEntriesNumber - 2) * 100;
else
    spontaneousAlternationPercent = 0;
end

% 输出结果到命令窗口
fprintf('\nResults:\n');
fprintf('Total Entries Number: %d\n', totalEntriesNumber);
fprintf('Spontaneous Alternation Number: %d\n', spontaneousAlternationNumber);
fprintf('Spontaneous Alternation Percent: %.2f%%\n', spontaneousAlternationPercent);

% 输出结果到Excel
T = table(totalEntriesNumber, spontaneousAlternationNumber, spontaneousAlternationPercent, ...
    'VariableNames', {'totalEntriesNumber', 'spontaneousAlternationNumber', 'spontaneousAlternationPercent'});
writetable(T, excel_filename);