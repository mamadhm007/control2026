%% Frequency Domain Analysis (Bode & Nyquist)
clear; clc; close all;

% 1. Define Linearized Transfer Function
% G(s) = 20 / (200s + 1)
num = [20];
den = [200 1];
sys = tf(num, den);

% 2. Bode Diagram Analysis
figure(1);
% دستور margin هم نمودار بود را میکشد و هم حاشیه پایداری را نشان میدهد
margin(sys); 
grid on;
title('Bode Diagram with Stability Margins');

% دریافت مقادیر دقیق حاشیه بهره و فاز
[Gm, Pm, Wcg, Wcp] = margin(sys);
Gm_dB = 20*log10(Gm); % تبدیل به دسی‌بل

disp('--------------------------------------------------');
disp('Frequency Response Characteristics:');
disp(['Gain Margin (GM): ', num2str(Gm_dB), ' dB']);
disp(['Phase Margin (PM): ', num2str(Pm), ' deg']);
disp(['Gain Crossover Frequency: ', num2str(Wcp), ' rad/s']);
disp('--------------------------------------------------');

% 3. Nyquist Diagram Analysis
figure(2);
nyquist(sys);
grid on;
title('Nyquist Diagram');
% افزودن دایره واحد و نقطه -1 برای تحلیل چشمی
hold on;
plot(-1, 0, 'rx', 'MarkerSize', 10, 'LineWidth', 2); % نقطه بحرانی -1
theta = 0:0.01:2*pi;
plot(cos(theta), sin(theta), 'k--'); % دایره واحد
legend('System Locus', 'Critical Point (-1,0)', 'Unit Circle');
axis([-2 22 -10 10]); % تنظیم محور برای دیدن شروع نمودار از 20