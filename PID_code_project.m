%% Controller Design (PID Tuning)
clear; clc; close all;

% 1. Define Plant
G = tf(20, [200 1]);

% 2. Design Parameters (Calculated)
% Goal: OS ~ 15%, Ts < 5s
% From hand calc: Kp ~ 20, Ki ~ 40
Kp = 20;
Ki = 18.5;
Kd = 1; % یک مقدار کوچک برای PID

% 3. Define Controllers
C_P = pid(Kp);              % P Controller
C_PI = pid(Kp, Ki);         % PI Controller
C_PD = pid(Kp, 0, Kd);      % PD Controller
C_PID = pid(Kp, Ki, Kd);    % PID Controller

% 4. Closed Loop Systems (Linear Analysis)
sys_cl_P = feedback(C_P * G, 1);
sys_cl_PI = feedback(C_PI * G, 1);
sys_cl_PD = feedback(C_PD * G, 1);
sys_cl_PID = feedback(C_PID * G, 1);

% 5. Plot Linear Step Responses
figure(1);
t = 0:0.01:10;
step(sys_cl_PI, 'b', sys_cl_PID, 'r--', t);
hold on;
yline(1, 'k:');
legend('PI Controller', 'PID Controller');
grid on;
title('Linear Step Response (Targeting OS~15%, Ts<5s)');

% Display Info
info_PI = stepinfo(sys_cl_PI);
disp('--- PI Controller Performance (Linear) ---');
disp(['Overshoot: ', num2str(info_PI.Overshoot), '%']);
disp(['Settling Time: ', num2str(info_PI.SettlingTime), ' s']);
disp(['Steady State Error: 0 (Due to Integrator)']);

%% 6. Analyze Saturation Effect (تحلیل اثر اشباع شیر)
% شیر ورودی فقط بین 0 تا 1 باز می‌شود.
% اما کنترلر ما (Kp=20) برای خطای 10 متر، فرمان u=200 می‌دهد!
% بیایید این را شبیه‌سازی کنیم:

sim_time = 0:0.01:20;
r = 10 * ones(size(sim_time)); % ورودی پله با دامنه 10 (ارتفاع هدف)

% تعریف مدل در سیمولینک یا حلقه دستی برای اعمال اشباع
% اینجا از یک حلقه ساده اویلر استفاده می‌کنیم
h = 0; % ارتفاع اولیه
u_I = 0; % مقدار انتگرال‌گیر
dt = 0.01;
h_history = [];
u_history = [];

for i = 1:length(sim_time)
    error = 10 - h; % Setpoint = 10
    
    % PID Calculation
    % P Term
    u_p = Kp * error;
    % I Term
    u_I = u_I + Ki * error * dt;
    % Total U (بدون محدودیت)
    u_raw = u_p + u_I;
    
    % اعمال محدودیت شیر (0 تا 1)
    if u_raw > 1
        u = 1; % اشباع بالا (شیر کاملاً باز)
        % Anti-Windup (توقف انتگرال‌گیری در اشباع)
        % u_I = u_I - Ki * error * dt; % (کد ساده آنتی‌واینداپ)
    elseif u_raw < 0
        u = 0; % اشباع پایین (شیر بسته)
    else
        u = u_raw;
    end
    
    % System Dynamics (Non-linear Plant approximation)
    % dh/dt = 0.1*u - 0.05*h (Linearized model for simplicity)
    dh = (20*u - h) / 200; 
    h = h + dh * dt;
    
    h_history(end+1) = h;
    u_history(end+1) = u;
end

figure(2);
subplot(2,1,1);
plot(sim_time, h_history, 'LineWidth', 2);
yline(10, 'g--');
grid on;
title('Realistic Response with Valve Saturation (0-100%)');
ylabel('Height (m)');

subplot(2,1,2);
plot(sim_time, u_history, 'r', 'LineWidth', 2);
yline(1, 'k--');
grid on;
title('Control Effort (Valve Position)');
ylabel('Valve (0-1)');
ylim([-0.1 1.2]);




