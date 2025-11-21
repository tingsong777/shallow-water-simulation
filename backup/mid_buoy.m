clc;
clear;
FILE_NAME = 'data/mid_150.mat';
load(FILE_NAME);

% 指定浮標位置
buoy = [10000, 100000, 200000, 300000];
num_buoys = length(buoy);

% 設定圖形視窗
figure;
tiledlayout(1,num_buoys, 'TileSpacing', 'Compact', 'Padding', 'Compact'); % 使用 tiledlayout 讓每個浮標的圖分開顯示

for i = 1:num_buoys
    % 找到最接近浮標位置的索引
    [~, x_index] = min(abs(x - buoy(i)));
    
    % 抓取這個浮標位置在全時長的 eta 資料
    eta_values = eta_time_series(:, x_index);
    
    % 找出這個位置 (x_index) 的最大 eta 值及對應的時間
    [eta_max_value, eta_max_index] = max(eta_values);
    recorded_time = t_series(eta_max_index);
    
    % 顯示結果
    fprintf('當 x = %.0f 時，eta 最大值為 %.4f，出現在時間點 t = %.4f 秒\n', buoy(i), eta_max_value, recorded_time);
    
    % 繪製全時長的 eta 圖
    nexttile; % 切換到下一個圖區塊
    plot(t_series, eta_values, 'k-', 'LineWidth', 1.5);
    hold on;
    % plot(recorded_time, eta_max_value, 'ro', 'MarkerSize', 8, 'DisplayName', '最大值');
    hold off;
    
    % 圖形標籤與標題
    xlabel('時間 (秒)');
    ylabel('\eta');
    % title(sprintf('x = %.0f 的全時長 \eta 圖', buoy(i)));
    % legend('show');
    grid on;
end
