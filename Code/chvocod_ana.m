% BE491 Group Digital Channel Vocoder Analyzer
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

function [y,p] = chvocod_ana(x, D, N, varargin)
%CHVOCOD_ANA Channel vocoder analyzer
%   [BAND_ENVELOPES,PITCH] = CHVOCOD_ANA(X,DECIMATE,N) 
%   encodes speech signal into pitch values and band envelope values
%   corresponding to a number of frequency channels
%   X              UNFILTERED speech signal that will be split into 30 ms frames
%   N              Number of frequency bands into which each 30ms frame is 
%                  split, enveloped, lowpass filtered, and decimated
%   varargin/Fs    Sampling frequency, default 8kHz
%   DECIMATE       Decimation factor by which the signal is decimated
%   BAND_ENVELOPES Y, Output return of decimated band envelope values,
%                  a matrix with size num_frames by N (where
%                  num_frames is the number of data frames dividing the 
%                  signal). 
%   PITCH          P, The pitch of each frame is detected by the pitch 
%                  detector, and the pitch outputs are returned in the 
%                  output variable.
%
%   This code has two separate stages, corresponding to the
%   source-filter model of speech production:
%   (1) The first stage involves characterizing the "source" by pitch detection.
%       Pitch detection is accomplished by breaking up the original signal
%       into frames and then determining if each frame is is voiced or unvoiced.
%       If the frame is voiced, then we also estimate the fundamental frequency
%       of the glottal source.
%   (2) The second stage involves characterizing the "filter", that is
%       determining the band envelope values.  This is accomplished by filtering
%       the original signal into frequency bands, determining the envelope of
%       each band and decimating.
%% Initialize variables
% Make x a column vector just to be sure.
x = x(:,1);
% Set sampling frequency
if nargin == 4
    Fs = varargin{1};
elseif nargin == 3
    Fs = 8000; % Hz
else
    error('You must enter 3 or 4 input arguments.');
end
% Set Nyquist frequency
Fny = Fs/2;
% Set low cutoff frequency of low pass filter for filtering the signal
FL = 350;  % [pitch is only 80-320 Hz for adult voices]
% Set filter order to filter the speech signal
order = 200;
% Set 30 ms frame length
frlen = floor(0.030 * Fs);
% Set frame number
    % Note that this depends on decimation rate
nframes = ceil(length(x)/D);
% Preallocate pitch vector output for speed
p = zeros(nframes, 1);
% Preallocate output matrix "y" for efficiency.
y = zeros(nframes,N);

%% Retrieve "source parameters" (pitch detection)
% (i) LPF the signal with 350 Hz cutoff frequency,
%     [pitch is only 80-320 Hz for adult voices]
%filtering the vowel to preserve only frequencies below 350Hz
Bfir1 = fir1(order, FL/Fny); %design lowpass filter by the windowing method
xlpf = fftfilt(Bfir1,x); %filtering the speech signal

%% Loop
% Each iteration processes one frame of data.
for i = 1:nframes
	startseg = (i-1)*D+1;
	endseg = startseg+frlen-1;
	if endseg > length(xlpf)
        endseg = length(xlpf);
    end
	seg = xlpf(startseg:endseg);
	% Call the pitch detector  
	p(i) = pitch_detect(seg);
    % Algorithm to determine the fundamental frequency of the voice
        % f = pitch__detect(filtered_signal);
        % x: a vector containing frame of speech data sampled at 8 kHz
        % clip_thresh: a scaling factor of the max/min values, 0.75 (75%) default
        % unvoiced_thresh: the minimum allowable relative pitch peak amplitude, 
        % below which the segment is considered unvoiced, 0.25 (25%) default
        % f: a scalar containing pitch of frame in Hz or 0 if unvoiced
end
% Remove spurious values from pitch signal with median filter
p = medfilt1(p, 65);

%% Determine band envelope values by setting filter parameters
% Compute FIR coefficients for filter bank (using 65-point filters).
% The variable bank should be a 65xN matrix with each column containing
% the impulse response of one filter
bank = filt_bank(N, 65);

%% Apply the filterbank to the input signal, x
% Process each band by looping
for i = 1:N
    % Apply filter for this band (bank(:,i)) to input x
     segbpf = fftfilt(bank(:,i),x);
    % Take magnitude of signal and decimate.
     segbpf = abs(segbpf);
    %Decimate
        % Note that MATLAB fcn 'decimate.m' includes lowpass filtering
     y(:,i) = decimate(segbpf,D);
% At this point, each row in Y has a length of D (number of points)
% resulting from the decimation. Since we also have D number of segments,
% Y is a matrix in which each column represents a segment of the signal
% and each row represents a band in the filter bank
end