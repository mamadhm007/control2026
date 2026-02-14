%% System Parameters Setup
% تعریف پارامترهای فیزیکی در ورک‌اسپیس
clear; clc;

model_name = 'geyrkhati_khati'; % اسم دقیق فایل سیمولینک خودت رو اینجا بنویس

area = 100;
inflow_gain = 10;
% نکته حیاتی: استفاده از ضریب اصلاح شده برای رسیدن به ارتفاع ۱۰
outflow_gain = 10 / sqrt(10); % حدود 3.162

% بارگذاری پارامترها در ورک‌اسپیس (چون سیمولینک از اینها می‌خونه)
assignin('base', 'area', area);
assignin('base', 'inflow', inflow_gain);
assignin('base', 'outflow', outflow_gain); % اگر در سیمولینک اسمش چیز دیگری است، تغییر بده

%% Operating Point Definition
% تعریف نقطه کار مطلوب
h_op = 10; % ارتفاع تعادل (State)
u_op = 1;  % ورودی تعادل (Input)

% بردار حالت و ورودی برای دستور linmod
x_op = [h_op]; % اگر سیستم تنها یک انتگرال‌گیر دارد، بردار حالت تک‌عضوی است
u_op = [u_op]; 

%% Linearization using linmod
% خطی‌سازی مدل سیمولینک حول نقطه کار تعریف شده
% [A, B, C, D] ماتریس‌های فضای حالت خطی شده هستند
[A, B, C, D] = linmod(model_name, x_op, u_op);

%% Convert to Transfer Function
% تبدیل فضای حالت به تابع تبدیل
[num, den] = ss2tf(A, B, C, D);
sys_linear = tf(num, den);

%% Display Result
disp('--------------------------------------------------');
disp('Linearized Transfer Function (Around h=10):');
sys_linear = minreal(sys_linear); % حذف صفر و قطب‌های مشترک احتمالی
disp(sys_linear);
disp('--------------------------------------------------');

% مقایسه با تحلیل دستی ما (جهت اطمینان)
% باید تقریبا برابر با 20 / (200s + 1) باشد