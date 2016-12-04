% BE491 Group Project Vowel Pitch Detection
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

%% This script is designed to show the inner workings of the analyzer by generating:
%       (1) plot the time domain of a stressed vowel, 
%       (2) plot the low-pass filtered time domain signal, 
%       (3) plot the center-clipped time domain signal, 
%       (4) plot the autocorrelation plot and demarcate the peak for 
%           fundamental frequency. (In the main script this is done
%           automatically, but for explanation's sake, we will show the
%           process here.)

%% Load the data in question
%  If the data is long, clip it to only a stressed vowel.
load cw161_8k.mat
% soundsc(cw161)
% Note the sampling rate
Fs = 8000; %Hz

% Isolate vowel
%   For this recording, I will clip to "ay."
 vowel = cw161(1980:2620); % "em"
% vowel = cw161(2.07E4:2.189E4);
% vowel = cw161(2.0E4:2.3E4);
soundsc(vowel)

%% Plot the time domain of a stressed vowel
figure
subplot(3,1,1)
% Plot the normalized magnitude of the utterance against a time axis 
plot((0:length(vowel)-1)/Fs, vowel/norm(vowel,inf), 'b-','Linewidth',2)
set(gca, 'FontSize', 20)
xlabel('Time (s)', 'FontSize', 30)
ylabel('Normalized Amplitude', 'FontSize', 30)
str = sprintf('Time Domain of Utterance');
title(str,'FontSize', 35)
legend('Original')
axis([-0.01 0.09 -1.1 1.1])

%% Plot the low-pass filtered time domain signal

subplot(3,1,2)
% Using code from chvocod_ana.m lines 46-51 and 62-67
    % Set Nyquist frequency
    Fny = Fs/2; %Hz
    % Set low cutoff frequency of low pass filter for filtering the signal
    % [pitch is only 80-320 Hz for adult voices]
    FL = 350; %Hz
    % Set filter order to filter the speech signal
    order = 200;
    % Design lowpass filter by the windowing method
    Bfir1 = fir1(order, FL/Fny);
    % Filtering the speech signal
    vowel_lpf = fftfilt(Bfir1, vowel); 

% Plot the normalized magnitude of the utterance against a time axis 
plot((0:length(vowel_lpf)-1)/Fs, vowel_lpf/norm(vowel_lpf,inf), 'Color', [0 0.447 0.741],'Linewidth',2)
set(gca, 'FontSize', 20)
xlabel('Time (s)', 'FontSize', 30)
ylabel('Normalized Amplitude', 'FontSize', 30)
str = sprintf('Time Domain of Low-Pass Filtered Utterance');
title(str,'FontSize', 35)
legend('200th-Order 350Hz LPF')
axis([-0.01 0.09 -1.1 1.1])

%% Plot the unoffset, center-clipped time domain signal
subplot(3,1,3)
% Using code from pitch_detect.m lines 39-51
    % Remove DC offset
    vowel_cclip = vowel - mean(vowel);
    % Find min and max samples, account for thresholds, and center clip using cclip function
    vowel_cclip = cclip(vowel_cclip, min(vowel_cclip)*0.75, max(vowel_cclip)*0.75);
    %{
        Center clips the signal x setting the lower and upper clipping 
        thresholds from the MINVAL and MAXVAL respectively. 
        Signal components between MINVAL and MAXVAL are 'center clipped', 
        while components below MINVAL are shifted up and compoents above 
        MAXVAL are shifted down. MINVAL must be negative and MAXVAL must 
        be positive. Each elements of X is processed as follows:
        If X(i) > MAXVAL, then Y(i) = X(i) ? MAXVAL;
        If MINVAL < X(i) < MAXVAL, then Y(i) = 0;
        If X(i) < MINVAL, then Y(i) = X(i) - MINVAL;
        Motivation:
        In order to use the autocorrelation function for automatic pitch 
        detection, it is helpful to suppress the peaks due to the vocal 
        tract transfer function. This center clipping will accomplish the 
        suppression.
    %} 

% Plot the normalized magnitude of the utterance against a time axis 
plot((0:length(vowel_cclip)-1)/Fs, vowel_cclip/norm(vowel_cclip,inf), 'Color',[0.302 0.745 0.933],'Linewidth',2)
set(gca, 'FontSize', 20)
xlabel('Time (s)', 'FontSize', 30)
ylabel('Normalized Amplitude', 'FontSize', 30)
str = sprintf('Time Domain of Unoffset, Center-Clipped Utterance');
title(str,'FontSize', 35)
leg = sprintf('DC-Offset removed,\nCenter-Clipped to 75%');
legend(leg)
axis([-0.01 0.09 -1.1 1.1])

%% Plot the autocorrelation plot
% Using code from pitch_detect.m lines 53-56
    % Compute the autocorrelation of the frame
    Rx = xcorr(vowel_cclip,'coeff'); 
    % Calculates the autocorrelation and also normalizes to 1
    % Note that the zeroth lag of the correlation, Rx[0], is in the middle of the output sequence.
    % Find the maximum peak following Rx[0] by calling peak function

%% Demarcate the peak for fundamental frequency 
% and print the number in the command window
pitch = pitch_detect(vowel_lpf);

% Using code from pitch_detect.m lines 58-69
    % Find the maximum peak following Rx[0] by calling peak function
    % To find the index of the maximum value; should be at Rx[0]
    max_index = find(Rx == max(Rx)); 
    % Extract the positive part of the correlation (e.g. on x axis)
    Rx_pos = Rx(max_index: length(Rx)); 
    % Find the maximum peak following Rx[0]
    [peakVAL, index] = peak(Rx_pos);
    %PEAK Detects autocorrelation fundamental peak
    %   [PEAKVAL, PEAKINDEX] = PEAK(X) locates the value and index of the largest
    %   peak in the vector X other than Rx[0].  X must be an autocorrelation
    %   function with maximum value Rx[0] as its first element.

% Plot the autocorrelation plot
figure
plot(((1:length(Rx))-max_index)/Fs, Rx, 'b','Linewidth',1)
hold on
% Plot the fundamental frequency
plot((index)/Fs, peakVAL,'o',...
    'LineWidth',5,...
    'MarkerSize',20,...
    'MarkerEdgeColor', [1 0 1],...
    'MarkerFaceColor', [1 0.8 1])
set(gca, 'FontSize', 35)
xlabel('Time Lag (s)', 'FontSize', 40)
ylabel('Normalized Correlation', 'FontSize', 40)
str = sprintf('Autocorrelation of Utterance');
title(str,'FontSize', 45)
legend('Autocorrelation', 'Fundamental Peak')
axis([-0.085 0.085 -0.3 1.1])

fprintf('The fundamental frequency of the utterance is %d.\n',pitch)

