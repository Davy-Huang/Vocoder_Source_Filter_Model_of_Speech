% BE491 Group Project Filter Bank Generator
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

function bank = filt_bank(N, L, varargin)
% FILT_BANK	Filter bank generator
%   BANK = FILT_BANK(N,L,Fs,B) generates a bank of filters where
%   N is the number of filter bands
%   L is the length of each FIR filter
%   Fs is the sampling frequency in Hz, default 8kHz
%   B is the width of each band in Hz
%   BANK is an LxN matrix, where each of the N columns of BANK contains an L-point FIR
%   filter.
%
%   BANK = FILT_BANK(N,L,Fs) automatically selects the bandwidth B so that the N
%   filters span the spectrum from 0 Hz to 3600 Hz.
%
%   BANK = FILT_BANK(N,L) sets Fs to 8000 Hz, and automatically selects the
%   bandwidth B so that the N filters span the spectrum from 0 Hz to 3600 Hz.

%% Process input
if nargin < 4
    B = 3600/N;  % set default width of each band in Hz
else
    B = varargin{2};
end
if nargin < 3
    Fs = 8000;   % set default sampling frequency in Hz
else
    Fs = varargin{1};
end
start = B/2;     % First center freq. in Hz
FL = B;          % Bandwidth in Hz

% Preallocate output for speed
bank = zeros(L,N);

% Determine Nyquist frequency
Fny = Fs/2;

%% Prototype LPF
    % Cutoff frequency chosen to obtain a bandwidth of B
    % Kaiser window with beta = 3
lpf = fir1(L-1,B/Fny,kaiser(L,3));
lpf = lpf(:); % Make LPF into a column vector

%% Create bandpass filters
    % By shifting the lowpass filter into a series of bandpass filters
% (i) Create a discrete-time column vector n for argument to cosines 
        % with length of the lowpass filter (L)
        % with spacing between the samples 1/Fs
n = ([0:L-1]/Fs)';

% (ii) Design filters for the remaining bands by looping
for i = 1:N
 % Compute desired center frequency from i, B, start, and Fs
 cf = i*B-start;
 % Shift lowpass prototype to center frequency
    if i==1
        bank(:,i) = lpf;
    else
        bank(:,i) = lpf .* cos(2*pi*cf*n)*2; 
    % Default calculations in MATLAB for cos are done in radians
    end
end

%% Extra code for plotting the frequency response of the filter bank
%{
F = 1:Fny;

figure
Band = abs(freqz(bank(:,1),1,F,Fs));
plot(F,Band,'r','Linewidth', 2)
xlabel('Frequency (Hz)', 'FontSize', 40)
ylabel('Amplitude', 'FontSize', 40)
title('Fundamental Frequency Response of the Filter Bank ','FontSize', 40)
axis([-100 4100 -0.1 1.1])
set(gca, 'FontSize', 25)

figure
hold on
plot(F,Band,'r--','Linewidth', 2)
for z=2:N
	Band = abs(freqz(bank(:,z),1,F,Fs));
	plot(F,Band,'b-','Linewidth', 2);
end
hold
xlabel('Frequency (Hz)', 'FontSize', 40)
ylabel('Amplitude', 'FontSize', 40)
str = sprintf('Frequency Response of the Filter Bank\nfor an 18-band 65th-order LPF');
title(str,'FontSize', 40)
legend('Fundamental Response','Response of Banked LPFs')
axis([-100 4100 -0.1 1.1])
set(gca, 'FontSize', 25)
%}
