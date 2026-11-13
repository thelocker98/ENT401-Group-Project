
clear;
clc;
close all;

s = serialport("COM6", 115200);
configureTerminator(s, "LF");
flush(s);

% Settings
windowSize = 10;

% Data storage
data = zeros(0, 3);
euclidean = zeros(0, 1);
time = zeros(0, 1);

tic;

% Create figure
figure('Name', 'BMX160 Live Acceleration', 'NumberTitle', 'off');

tiledlayout(2, 1);

% 1. X, Y, Z acceleration
ax1 = nexttile;
hAccel = plot(ax1, nan, nan, nan, nan, nan, nan);
title(ax1, "BMX160 Acceleration");
xlabel(ax1, "Time (seconds)");
ylabel(ax1, "Acceleration (g)");
legend(ax1, "X", "Y", "Z");
grid(ax1, "on");

% 2. Euclidean magnitude
ax2 = nexttile;
hEuclidean = plot(ax2, nan, nan);
title(ax2, "Euclidean Acceleration Magnitude");
xlabel(ax2, "Time (seconds)");
ylabel(ax2, "Acceleration (g)");
legend(ax2, "Euclidean Magnitude");
grid(ax2, "on");

while ishandle(ax1)

    line = readline(s);
    values = sscanf(line, 'a/g:%f%f%f');

    if numel(values) ~= 3
        continue;
    end

    % Extract acceleration and convert m/s^2 to g
    accel = values(1:3)' / 9.81;

    % Store measurements
    t = toc;

    data(end+1, :) = accel;
    time(end+1, 1) = t;

    % Euclidean magnitude in g
    magnitude = sqrt(sum(accel.^2));

    euclidean(end+1, 1) = magnitude;

    % Keep only recent samples
    while time(end) - time(1) > windowSize
        data(1,:) = [];
        euclidean(1) = [];
        time(1) = [];
    end

    % Update X, Y, Z plot
    for i = 1:3
        set(hAccel(i), ...
            'XData', time, ...
            'YData', data(:,i));
    end

    % Update Euclidean magnitude plot
    set(hEuclidean, ...
        'XData', time, ...
        'YData', euclidean);

    % Scroll time axes
    xLimits = [max(0,t-windowSize), max(windowSize,t)];

    xlim(ax1, xLimits);
    ylim(ax1, [-3 3]);
    xlim(ax2, xLimits);
    ylim(ax2, [-3 3]);


    drawnow limitrate;
end

clear s;
