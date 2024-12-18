clear all; close all;

% 改变工作目录
cd('C:\Users\Haoshen Xu\Documents\MATLAB');

% 读取数据并去除NaN数据
data = readmatrix('test.txt');
nonNanIndices = all(~isnan(data), 2);
data = data(nonNanIndices, :);

% 检查数据维度
if size(data, 2) ~= 2
    error('Data must have two columns.');
end

% 提取x和y值
X = data(:, 1);
Y = data(:, 2);

display(X);
