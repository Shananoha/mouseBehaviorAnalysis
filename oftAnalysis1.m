clear; close all;
% 指定文件路径
filename = 'e2.txt'; % 文件名

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
    data = textscan(fid, '%f%f%f', 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    data = cell2mat(data);
    fclose(fid);
end

% 分离X和Y坐标
X = data(:, 1);
Y = data(:, 2);

% 绘制轨迹图
figure; % 创建一个新的图形窗口
plot(X, Y, 'r-'); % 绘制红色线图，'r-'表示红色实线
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

% 保存图形（如果需要）
saveas(gcf, 'e1.tif');