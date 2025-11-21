clc;
clear;

% 設定檔案名稱和路徑
FOLDER_NAME = '2025_midterm_bathymetry';
FILE_NAME = '2025_midterm_bathymetry_meters.mat';
FULL_PATH = fullfile(FOLDER_NAME, FILE_NAME);

% 讀取檔案
load(FULL_PATH);

% 檢查變數是否存在
if ~exist('x', 'var') || ~exist('h', 'var')
    error('檔案中沒有變數 x 或 h');
end

% 繪圖
figure;
plot(x, -h, 'b-', 'LineWidth', 1.5);
xlabel('x (meters)');
ylabel('h (meters)');
title('Bathymetry Profile');
grid on;
