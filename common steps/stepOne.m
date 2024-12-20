clear all; close all;

% 改变工作目录
cd('C:\Users\Haoshen Xu\Documents\MATLAB');

% 定义文件名的各个部分
pfix1 = 'e1'; % 文件名前缀
pfix2 = 'result'; % 文件名前缀2
sfix1 = '.txt'; % 数据文件后缀
sfix2 = '.tif'; % 图片文件后缀
sfix3 = '.xlsx'; % 结果文件后缀

% 指定文件路径
fileName = [pfix sfix1]; % 定义数据文件名
tifName = [pfix sfix2]; % 定义图片名
resultName = [pfix sfix3]; % 定义结果文件名

% 读取数据并去除NaN数据
data = readmatrix(fileName);
nonNanIndices = all(~isnan(data), 2);
data = data(nonNanIndices, :);

% 提取x和y值
X = data(:, 1);
Y = data(:, 2);

% 绘制轨迹图
fig1 = figure('Color', 'w', 'InvertHardcopy', 'off'); % 创建一个新的图形窗口并设置背景为白色
plot(X, Y, 'r-'); % 绘制红色线图，'r-'表示红色实线
% 设置坐标轴背景为透明，坐标轴颜色为透明，刻度为空
set(gca, 'Color', 'none', 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', []); 

% 保存图形
print(fig1, tifName, '-dtiff', '-r300'); % 转换为TIFF格式，分辨率为300dpi
close(fig1); % 关闭图形窗口
