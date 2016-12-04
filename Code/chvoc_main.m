% BE491 Group MAIN SCRIPT for saving sound files and formatting figures in
% the presentation and report
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

%% This script is designed to:
%       (1) Record an utterance and format this object into a format that
%           can be read into the channel vocoder.
%       (1) Determine the pitch values produced for the entire utterance and 
%           compare to the performance of the automated pitch detector to 
%           the original signal. Though it will not be perfect, our results 
%           are reasonable. 
%       (2) Produce monotone, whispered, male, and female utterances by 
%           changing the pitch vector.

%% Record utterance and format for the channel vocoder
%{
Set recording time
duration = 5; %s
% Create recording object
Fs_o = 44100;
SNDREC = audiorecorder(Fs_o, 16, 1);
    % creates a 16 bit, 1 channel audiorecorder object

% Collection
pause(1)
disp('Start speaking.');
recordblocking(SNDREC, duration);
disp('End of recording.');

% Extract data
snd.data = getaudiodata(SNDREC);
audiowrite('signal_44k_BlakeP.wav', snd.data, Fs_o);
% obj_rec = audioplayer(signal_object.data, Fs_o);

% Resample the data at 8kHz to minimize processing time and work best with chvoc
signal_o = resample(snd.data, 2, 11);
Fs = 8E3;

% Blake: Not sure if lines 39-46 are absolutely necessary, but they seem to be nice
% Write audio file from data
    % Option to save original, unsampled recording:
    % audiowrite('signal_original.wav', signal_object.data, Fs_o);
audiowrite('signal_8k_BlakeP.wav', signal_o, Fs);

% Read
[signal_o, Fs] = audioread('signal_8k_Blake2.wav');
% soundsc(signal_o, Fs);
%}
%% Run through the Channel Vocoder
% The empty flask stood on the tin tray
load cw161_8k.mat
Fs = 8000; %Hz
signal_o = cw161;
audiowrite('cw161_o.wav', signal_o/norm(signal_o,inf), Fs);
D = 10;
N = 18;
[signal_synPI, Fs] = chvoc_over(signal_o, D, N, Fs, 'PI');
sound(signal_synPI)
audiowrite('cw161_synPI.wav', signal_syn, Fs);
    % chvoc_over generates a NORMALIZED signal synthesized in the channel vocoder, 
    %  as well as returning the Fs and the pitch vector
    % Inputs include:
    % varargin{1} can be used to specify the sampling frequency, default 8kHz
    % varargin{2} can also be used as a string input to change the voice:
        % ORIGINAL: Leave pitch vector (p) as is; this is default
        %  p = p;
        % FEMALE: Multiply pitch vector (p) by a factor of 2
        %  p = p * 2;
        % MALE:   Multiply pitch vector (p) by a factor of 0.5
        %  p = p * 0.5;
        % WHISPER: Set pitch vector (p) to zeros
        %  p = zeros(1,length(p));
        % MONOTONE: Set pitch vector (p) to contsant value (eg. 100Hz)
        %  p= ones(1,length(p)).*100;
        
%% Time Domain Plot
%{
figure
plot((0:length(signal_o)-1)/Fs, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
hold on
plot((0:length(signal_syn)-1)/Fs, signal_syn, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
xlabel('Time (s)', 'FontSize', 30)
ylabel('Normalized Amplitude', 'FontSize', 30)
str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
title(str,'FontSize', 35)
legend('Recorded', 'Synthesized in Channel Vocoder')
axis([-0.1 3.1 -1.1 1.1])
set(gca, 'FontSize', 20)
%}
%% Spectrogram plot

%{
figure
subplot(2,1,1)
[So,Fo,To] = spectrogram(snd.data,2^10,2^9,[],Fs_o);
set(gcf,'windowstyle','docked')
imagesc(To,Fo,20*log10(abs(So)),[-126 34])
colorbar
axis xy
set(gca, 'FontSize', 25)
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 35)
title('Spectrogram for Utterrance as Originally Recorded','FontSize', 35)
ylim([0 Fs_o/2])

%}
figure
subplot(1,3,1)
[So,Fo,To] = spectrogram(signal_o/norm(signal_o,inf),2^10,2^9,[],Fs);
set(gcf,'windowstyle','docked')
imagesc(To,Fo,20*log10(abs(So)),[-126 34])
% colorbar
axis xy
set(gca, 'FontSize', 25)
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 30)
str = sprintf('Original Utterrance');
title(str,'FontSize', 30)
ylim([0 Fs/2])

subplot(1,3,2)
[S_syn,F_syn,T_syn] = spectrogram(signal_synOR,2^10,2^9,[],Fs);
% set(gcf,'windowstyle','docked')
imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
% colorbar
set(gca, 'FontSize', 25)
axis xy
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 30)
str = sprintf('"Original" Synthesized');
title(str,'FontSize', 30)
ylim([0 Fs/2])

subplot(1,3,3)
[S_syn,F_syn,T_syn] = spectrogram(signal_synMA,2^10,2^9,[],Fs);
% set(gcf,'windowstyle','docked')
imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
colorbar
set(gca, 'FontSize', 25)
axis xy
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 30)
str = sprintf('"Male" Synthesized');
title(str,'FontSize', 30)
ylim([0 Fs/2])

%%
figure
set(gcf,'windowstyle','docked')
subplot(1,3,1)
[S_syn,F_syn,T_syn] = spectrogram(signal_synFE,2^10,2^9,[],Fs);
% set(gcf,'windowstyle','docked')
imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
% colorbar
set(gca, 'FontSize', 25)
axis xy
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 30)
str = sprintf('"Female" Synthesized');
title(str,'FontSize', 30)
ylim([0 Fs/2])

subplot(1,2,2)
[S_syn,F_syn,T_syn] = spectrogram(signal_synMO,2^10,2^9,[],Fs);
% set(gcf,'windowstyle','docked')
imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
% colorbar
set(gca, 'FontSize', 25)
axis xy
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 30)
str = sprintf('"Monotone" Synthesized');
title(str,'FontSize', 30)
ylim([0 Fs/2])

subplot(1,3,3)
[S_syn,F_syn,T_syn] = spectrogram(signal_synWH,2^10,2^9,[],Fs);
% set(gcf,'windowstyle','docked')
imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
% colorbar
set(gca, 'FontSize', 25)
axis xy
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 30)
str = sprintf('"Whispered" Synthesized');
title(str,'FontSize', 30)
ylim([0 Fs/2])
%%
subplot(1,3,3)
[S_syn,F_syn,T_syn] = spectrogram(signal_synWH2,2^10,2^9,[],Fs);
% set(gcf,'windowstyle','docked')
imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
% colorbar
set(gca, 'FontSize', 25)
axis xy
xlabel('Time (s)','FontSize', 35)
ylabel('Frequency (Hz)','FontSize', 30)
str = sprintf('"Pitchless" Synthesized');
title(str,'FontSize', 30)
ylim([0 Fs/2])