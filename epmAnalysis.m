clear all; close all;

% 步骤1: 读取txt文件中的XY坐标

% 定义文件名的各个部分
prefix = 'e15'; % 文件名前缀
suffix1 = '.txt'; % 文件后缀
suffix2 = '.xlsx'; % 文件后缀
suffix3 = '.tif'; % 文件后缀

% 指定文件路径
filename = [prefix suffix1]; % 文件名

% 指定导出的Excel文件名
excel_filename = [prefix suffix2]; % 你可以根据需要修改这个文件名

% 定义图片名变量
tifname = [prefix suffix3];

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

x = data(:,1);
y = data(:,2);

% 步骤2: 绘制轨迹图
figure; % 创建一个新的图形窗口
plot(x, y, 'r-'); % 使用红色实线绘制轨迹
hold on; % 保持图像，以便在同一个图上绘制ROI

% 步骤3: 绘制ROI区域
% ROI1
X1 = [120, 284, 284, 120, 120];
Y1 = [230, 230, 275, 275, 230];
plot(X1, Y1, 'k--'); % 使用黑色虚线绘制ROI1

% ROI2
X2 = [330, 494, 494, 330, 330];
Y2 = [230, 230, 275, 275, 230];
plot(X2, Y2, 'k--'); % 使用黑色虚线绘制ROI2

% ROI3
X3 = [284, 330, 330, 284, 284];
Y3 = [55, 55, 230, 230, 55];
plot(X3, Y3, 'k-'); % 使用黑色实线绘制ROI3

% ROI4
X4 = [284, 330, 330, 284, 284];
Y4 = [275, 275, 450, 450, 275];
plot(X4, Y4, 'k-'); % 使用黑色实线绘制ROI4

% 步骤4: 去除背景和坐标轴
title(' '); % 移除标题
xlabel(' '); % 移除X轴标签
ylabel(' '); % 移除Y轴标签
grid off; % 关闭网格
axis off; % 关闭坐标轴

% 设置背景为透明
set(gca, 'Color', 'none'); % 设置当前坐标轴的背景为透明
set(gcf, 'Color', 'w'); % 设置图形窗口的背景为透明

% 保持图形，防止被覆盖
hold off;

% 保存图形（如果需要）
saveas(gcf, tifname); % 使用变量保存文件

% 总帧数和总时间
totalFrames = 9000;
totalTime = 300; % 5分钟转换为秒

% 定义ROI区域
ROI1 = [55, 120, 120, 55, 55; 230, 230, 275, 275, 230];
ROI2 = [330, 494, 494, 330, 330; 230, 230, 275, 275, 230];
ROI3 = [120, 330, 330, 120, 120; 55, 55, 230, 230, 55];
ROI4 = [120, 330, 330, 120, 120; 275, 275, 450, 450, 275];
ROI5 = [120, 330, 330, 120, 120; 230, 230, 275, 275, 230];

% 计算每个点是否在每个ROI内
isInROI1 = inpolygon(x, y, ROI1(1, :), ROI1(2, :));
isInROI2 = inpolygon(x, y, ROI2(1, :), ROI2(2, :));
isInROI3 = inpolygon(x, y, ROI3(1, :), ROI3(2, :));
isInROI4 = inpolygon(x, y, ROI4(1, :), ROI4(2, :));
isInROI5 = inpolygon(x, y, ROI5(1, :), ROI5(2, :));

% 计算进入开臂和闭臂的次数
openArmEntry = 0;
closedArmEntry = 0;
for i = 2:length(x)
    if (isInROI1(i) || isInROI2(i)) && (isInROI1(i-1) == 0 && isInROI2(i-1) == 0)
        openArmEntry = openArmEntry + 1;
    end
    if (isInROI3(i) || isInROI4(i)) && (isInROI3(i-1) == 0 && isInROI4(i-1) == 0)
        closedArmEntry = closedArmEntry + 1;
    end
end

% 计算在每个区域的活动时间
openArmTime = sum(isInROI1 | isInROI2) / 30; % 转换为秒
closedArmTime = sum(isInROI3 | isInROI4) / 30; % 转换为秒
centerTime = sum(isInROI5) / 30; % 转换为秒

% 计算总路程和中央区域路程
totalDistance = sum(sqrt(diff(x).^2 + diff(y).^2));
centerDistance = sum(sqrt(diff(x(isInROI5)).^2 + diff(y(isInROI5)).^2));

% 显示结果
fprintf('Open Arm Entry: %d\n', openArmEntry);
fprintf('Open Arm Time: %f s\n', openArmTime);
fprintf('Closed Arm Entry: %d\n', closedArmEntry);
fprintf('Closed Arm Time: %f s\n', closedArmTime);
fprintf('Center Time: %f s\n', centerTime);
fprintf('Total Distance: %f\n', totalDistance);


% 创建一个表格来存储结果
results = table(openArmEntry, openArmTime, closedArmEntry, closedArmTime, centerTime, totalDistance, centerDistance, ...
    'VariableNames', {'OpenArmEntry', 'OpenArmTime_s', 'ClosedArmEntry', 'ClosedArmTime_s', 'CenterTime_s', 'TotalDistance', 'CenterDistance'});

% 将结果写入Excel文件
writetable(results, excel_filename);

disp(['Results have been exported to ', excel_filename]);