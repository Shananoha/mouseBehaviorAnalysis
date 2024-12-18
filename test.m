clear all; close all;

% 改变工作目录
cd('C:\Users\Haoshen Xu\Documents\MATLAB');

% 读取数据并去除NaN数据
data = readmatrix('test.txt');
nonNanIndices = all(~isnan(data), 2);
data = data(nonNanIndices, :);

% 提取x和y值
X = data(:, 1);
Y = data(:, 2);

% 绘制轨迹图
fig = figure('Color', 'w', 'InvertHardcopy', 'off'); % 创建一个新的图形窗口并设置背景为白色
plot(X, Y, 'r-'); % 绘制红色线图，'r-'表示红色实线
% 设置坐标轴背景为透明，坐标轴颜色为透明，刻度为空
set(gca, 'Color', 'none', 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', []); 

% 保存图形
print(fig, 'test', '-dtiff', '-r300'); % 转换为TIFF格式，分辨率为300dpi
close(fig); % 关闭图形窗口