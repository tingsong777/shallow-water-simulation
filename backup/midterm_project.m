clc; close all; clear;

tic;

% fixed dx
dx = 250;
save_on =1;
FILE_NAME = sprintf ('data/mid_%d.mat',dx);
% given parameters
CFL = 0.9;
L = 100000;
H = 1;
h_max = 5500;
x0 = 400000;
t0 = 0;
g = 9.81;
C = sqrt(g*h_max);
K = 2*pi / L;
t_max = 3500;



% spatial setup
x = 0:dx:5*10^5;
nx = length(x);
% time setup
dt = CFL*dx/C;
t_now = 0;

% initialization
eta = zeros(1,nx+4);
U = zeros(1,nx+4);
eta_1 = zeros(1,nx+4);
eta_2 = zeros(1,nx+4);
U_1 = zeros(1,nx+4);
U_2 = zeros(1,nx+4);

% extent x 
x_ext = [-2*dx,-dx,x,x(end)+dx,x(end)+2*dx];

% 突然深度變化設定
h = zeros(1, nx+4);
x_transition = 200000;  % 斜率轉換點的位置 (h2 到 h3 的過渡點)
% h1, h2, h3 的定義
h1 = 10;
h2 = 2510;
h3 = 5500;

% 斜率設定
slope = 1/76;  % 斜率 1/76
s = 10;

% 建立 h 的分布
for j = 3:nx+2
    if x_ext(j) >= 0 && x_ext(j) <= 10000  % 正確判斷0到10的範圍
        h(j) = h1;
        
    elseif x_ext(j) > 10000 && x_ext(j) < x_transition  % 緩慢上升區域 (線性變化)
        h(j) = h1 + slope * (x_ext(j) - 10000);  % 緩慢上升從 x = 10000 開始
        
    elseif x_ext(j) >= x_transition  % 後段平滑過渡 (tanh)
        h(j) = h2 + (h3 - h2) * 0.5 * (1 + tanh(s * (x_ext(j) - x_transition)));
    end
end

% 確保邊界資料也正確設定
h(1:2) = h(3);
h(end-1:end) = h(end-2);


% I.C.
for j = 3:nx+2
    eta(1,j) = H*(sech(K*(x_ext(j-2)-x0-C*t0))).^2;
    U(1,j) = -eta(1,j)*C/h(j-2);
end
t_series = [0];  % Store time steps
eta_time_series = eta;  % Store eta at each time step
U_time_series = U;      % Store U at each time step
% 時間步數設定
nt = ceil(t_max / dt);  % 總共需要的時間步數


 % time marching (RK3 & 4-th central diff)
    for i = 1:nt-1
        % 更新時間
        t_now = i * dt;
        t_series(i+1) = t_now;
        
        % 顯示時間進度
        fprintf('Time progress: %.2f / %.2f sec (%.2f%%)\n', t_now, t_max, (t_now/t_max)*100);

        eta_1(i,:) = eta(i,:);
        U_1(i,:) = U(i,:);
        eta_2(i,:) = eta(i,:);
        U_2(i,:) = U(i,:);
        %============
        % first round
        %============
        for j = 3:nx+2
            eta_1(j) = eta(i,j) - (dt/12/dx) * (-U(i,j+2)*h(j+2)+ ...
                8*U(i,j+1)*h(j+1)-8*U(i,j-1)*h(j-1)+U(i,j-2)*h(j-2));
            U_1(j) = U(i,j) - (dt/12/dx*g) * (-eta(i,j+2)+8*eta(i,j+1) ...
                -8*eta(i,j-1)+eta(i,j-2));
        end
        % apply B.C.
        eta_1(1) = eta_1(5);
        eta_1(2) = eta_1(4);
        eta_1(end-1) = eta_1(end-2)-dx/C*(eta_1());
        eta_1(end) = eta_1(end-4);
        U_1(1) = -U_1(5);
        U_1(2) = -U_1(4);
        U_1(end-1) = -U_1(end-3);
        U_1(end) = -U_1(end-4);
        %=============
        % second round
        %============= 
        for j = 3:nx+2
            eta_2(j) = (3/4) * eta(i,j) + (1/4) * (eta_1(j) - (dt/12/dx)* ...
                (-U_1(j+2)*h(j+2)+8*U_1(j+1)*h(j+1)-8*U_1(j-1)*h(j-1)+U_1(j-2)*h(j-2)));
            U_2(j) = (3/4) * U(i,j)+ (1/4)*(U_1(j)-(dt/12/dx*g) * ...
                (-eta_1(j+2) + 8*eta_1(j+1) - 8*eta_1(j-1) + eta_1(j-2)));
        end
        % apply B.C.
        eta_2(1) = eta_2(5);
        eta_2(2) = eta_2(4);
        eta_2(end-1) = eta_2(end-3);
        eta_2(end) = eta_2(end-4);
        U_2(1) = -U_2(5);
        U_2(2) = -U_2(4);
        U_2(end-1) = -U_2(end-3);
        U_2(end) = -U_2(end-4);
        %=============
        % third round
        %============= 
        for j = 3:nx+2
            eta(i+1,j) = (1/3)*eta(i,j) + (2/3)*(eta_2(j)-(dt/12/dx)* ...
                (-U_2(j+2)*h(j+2)+8*U_2(j+1)*h(j+1)-8*U_2(j-1)*h(j-1)+U_2(j-2)*h(j-2)));
            U(i+1,j) = (1/3)*U(i,j) + (2/3)*(U_2(j)-(dt/12/dx*g)* ...
                (-eta_2(j+2)+8*eta_2(j+1) - 8*eta_2(j-1)+eta_2(j-2)));
        end
        % apply B.C.
        eta(i+1,1) = eta(i+1,5);
        eta(i+1,2) = eta(i+1,4);
        eta(i+1,end-1) = eta(i+1,end-3);
        eta(i+1,end) = eta(i+1,end-4);
        U(i+1,1) = -U(i+1,5);
        U(i+1,2) = -U(i+1,4);
        U(i+1,end-1) = -U(i+1,end-3);
        U(i+1,end) = -U(i+1,end-4);
        
    end


elapsedTime = toc;
fprintf('運行時間：%.4f 秒\n', elapsedTime);
if save_on == 1
    save(FILE_NAME)
    fprintf('Results saved to %s\n', FILE_NAME);
end