%% Open-Loop Analysis (Updated)
clear; clc; close all;

%% 1. Define System Model
% تابع تبدیل خطی شده حول نقطه کار h=10
% G(s) = 20 / (200s + 1)
num = [20];
den = [200 1];
sys = tf(num, den);

%% 2. Step Response (پاسخ پله)
figure(1);
% حذف ضریب 0.05 و استفاده از پله واحد (دامنه 1)
step(sys); 
grid on;
title('Step Response (Unit Step Input)');
ylabel('Height Deviation (m)');
xlabel('Time (s)');

% دریافت اطلاعات دقیق
info = stepinfo(sys);
disp('--- Step Response Info ---');
disp(['Final Value: ', num2str(20)]); % چون بهره 20 است
disp(['Settling Time: ', num2str(info.SettlingTime)]);
disp(['Rise Time: ', num2str(info.RiseTime)]);

%% 3. Impulse & Ramp Response (ضربه و شیب)
figure(2);

% الف) پاسخ ضربه
subplot(2, 1, 1);
impulse(sys);
grid on;
title('Impulse Response');
ylabel('Height Rate (m/s)');

% ب) پاسخ شیب (Ramp)
subplot(2, 1, 2);
t_ramp = 0:1:1000; 
u_ramp = t_ramp; % ورودی رمپ با شیب 1
[y_ramp, t_out] = lsim(sys, u_ramp, t_ramp);

plot(t_out, y_ramp, 'LineWidth', 2);
hold on;
% رسم خط ورودی برای مقایسه
plot(t_ramp, u_ramp, 'r--', 'LineWidth', 1); 
grid on;
title('Ramp Response (Linear Model)');
legend('System Output', 'Ramp Input');
xlabel('Time (s)');
ylabel('Height (m)');

% توضیحات در پنجره فرمان برای کاربر
disp('--- Ramp Analysis ---');
disp('Note: The huge output value in Ramp Response is mathematically correct due to Linear Model Gain (K=20).');
disp('In reality, the tank would overflow at 10m.');