clear; close all;
% 指定文件路径
filename = 'ex7 no27.txt'; % 文件名


% 指定导出的Excel文件名
excel_filename = 'ex7 no27.xlsx'; % 你可以根据需要修改这个文件名


% 读取数据
data = load(filename);

% 分离X和Y坐标
X = data(:, 1);
Y = data(:, 2);

% 确定坐标的极值
X_min = min(X);
X_max = max(X);
Y_min = min(Y);
Y_max = max(Y);

% 确定区域大小
grid_size_x = (X_max - X_min) / 4;
grid_size_y = (Y_max - Y_min) / 4;

% 定义中心区域的坐标范围
center_region_x = [X_min + grid_size_x, X_min + 3*grid_size_x];
center_region_y = [Y_min + grid_size_y, Y_min + 3*grid_size_y];

% 初始化总路程和中心区内路程
total_distance = 0;
center_distance = 0;

% 初始化总时间
total_time = 0;
center_time = 0;

% 初始化进入中心区域的次数
enter_center_count = 0;

% 假设时间戳存储在第三个列（如果存在）
if size(data, 2) > 2
    time_stamps = data(:, 3);
else
    time_stamps = (1:length(X))'; % 如果没有时间戳，假设时间是连续的
end

% 初始化isInCenter向量
isInCenter = zeros(1, length(X));
for i = 1:length(X)
    isInCenter(i) = X(i) >= center_region_x(1) && X(i) <= center_region_x(2) && Y(i) >= center_region_y(1) && Y(i) <= center_region_y(2);
end

% 计算总路程
for i = 1:length(X)-1
    distance = sqrt((X(i+1) - X(i))^2 + (Y(i+1) - Y(i))^2);
    total_distance = total_distance + distance;
    total_time = total_time + (time_stamps(i+1) - time_stamps(i));
    
    % 检查点是否在中心区域
    if isInCenter(i)
        center_distance = center_distance + distance;
        center_time = center_time + (time_stamps(i+1) - time_stamps(i));
    end
end

% 计算进入中心区域的次数
entryTimes = 0;
for i = 2:length(isInCenter)
    if isInCenter(i) == 1 && isInCenter(i-1) == 0
        entryTimes = entryTimes + 1; % Increment when a transition occurs
    end
end

% 将距离转换为毫米
total_distance_mm = total_distance * 0.05;
center_distance_mm = center_distance * 0.05;

% 显示结果
fprintf('总路程: %.2f mm\n', total_distance_mm);
fprintf('中心区内总路程: %.2f mm\n', center_distance_mm);
fprintf('总时间: %.2f 单位时间\n', total_time);
fprintf('中心区内总时间: %.2f 单位时间\n', center_time);
fprintf('进入中心区的次数: %d\n', entryTimes);

% 创建一个表格来存储结果
results = table(total_distance_mm, center_distance_mm, total_time, center_time, entryTimes, ...
    'VariableNames', {'TotalDistance_mm', 'CenterDistance_mm', 'TotalTime', 'CenterTime', 'EnterCenterCount'});

% 将结果写入Excel文件
writetable(results, excel_filename);

disp(['Results have been exported to ', excel_filename]);