clc; clear; close all;

% 設定檔案名稱 (根據 dx 設定)
dx = 250;
FILE_NAME = sprintf('data/mid_%d.mat', dx);

% 讀取檔案
load(FILE_NAME);

% 確認變數存在
if ~exist('x', 'var') || ~exist('eta', 'var') || ~exist('t_series', 'var') || ~exist('h', 'var')
    error('檔案中沒有變數 x、eta、t_series 或 h');
end

% 設定要繪製的特定時間點
special_times = [0, 600, 1200, 1800, 2400, 3150];

% 找到對應的時間點 index
special_indices = arrayfun(@(t) find(t_series >= t, 1, 'first'), special_times, 'UniformOutput', false);
special_indices = cell2mat(special_indices);  % 將 Cell Array 轉換成數值矩陣

% 設定顏色 (MATLAB 預設色系)
colors = lines(length(special_times));

% 繪圖範圍設定
y_min = min(eta(:));
y_max = max(eta(:));

% 繪製特定時間點的曲線 (靜態圖)
figure;
subplot(2,1,1);
hold on;
for i = 1:length(special_times)
    eta_snapshot = eta(special_indices(i), 3:end-2);  % 去掉邊界資料
    plot(x, eta_snapshot, 'LineWidth', 1.5, 'Color', colors(i, :), 'DisplayName', sprintf('t = %d s', special_times(i)));
end

% 圖表設定
xlabel('x (meters)');
ylabel('\eta');
title('Wave Shape at Different Time Points');
ylim([y_min, y_max]);
grid on;
legend show;
hold off;

% 繪製 h (深度分佈)
subplot(2, 1, 2);
hold on;
plot(x, -h(3:end-2), 'b-', 'LineWidth', 1.5);
xlabel('x (meters)');
ylabel('Depth (h)');
title('Depth Profile');
grid on;
hold off;

% 動態展示 (動畫) 開在新的 figure 中
figure;
h_plot = plot(x, eta(1, 3:end-2), 'b-', 'LineWidth', 1.5);
xlabel('x (meters)');
ylabel('\eta');
ylim([y_min, y_max]);
title('Wave Shape Animation');
grid on;

% 動畫播放
for k = 1:size(eta, 1)
    eta_snapshot = eta(k, 3:end-2);
    set(h_plot, 'YData', eta_snapshot);
    title(sprintf('Wave Shape at t = %.1f s', t_series(k)));
    pause(0.01);  % 調整這個值可以控制動畫速度 (0.01 是比較流暢的)
    drawnow limitrate;
end



