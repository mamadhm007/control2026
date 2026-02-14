%% Stability Analysis of Water Tank System
clear; clc; close all;

% 1. Define Linearized Model (G(s) = 20 / (200s + 1))
num = [20];
den = [200 1];
sys = tf(num, den);

% 2. Pole-Zero Map
figure(1);
pzmap(sys);
grid on;
title('Pole-Zero Map of the System');
sgrid;

% 3. Extract Poles
poles = pole(sys);
disp('--------------------------------------------------');
disp('System Poles:');
disp(poles);

% 4. Routh-Hurwitz Check
disp('--------------------------------------------------');
disp('Characteristic Equation Coefficients:');
disp(['a1 (s^1): ', num2str(den(1))]);
disp(['a0 (s^0): ', num2str(den(2))]);

if all(den > 0)
    disp('Result: All coefficients are positive -> System is Stable.');
else
    disp('Result: Unstable.');
end
disp('--------------------------------------------------');