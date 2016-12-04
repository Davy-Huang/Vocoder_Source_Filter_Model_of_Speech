% BE491 Group Project Autocorrelation Algorithm
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

% Algorithm to determine the fundamental frequency of the voice
function pitch = pitch_detect(x, varargin)
% x        vector containing frame of speech data sampled at Fs 
% varargin 
%      clip_thresh:a scaling factor of the max/min values, 0.75 (75%) default
%      unvoiced_thresh: the minimum allowable relative pitch peak amplitude, 
%         below which the segment is considered unvoiced, 0.25 (25%) default
%      Fs: sampling frequency, default 8 kHz
% pitch: a scalar containing pitch of frame in Hz or 0 if unvoiced

%% Check input arguments
if nargin == 0
    error('You must enter a filtered speech signal.');
elseif nargin == 1
    clip_thresh = 0.75;
    unvoiced_thresh = 0.25;
    Fs = 8000; %Hz
elseif nargin == 2
    clip_thresh = varargin{1};
    unvoiced_thresh = 0.25;
    Fs = 8000; %Hz
elseif nargin == 3
    clip_thresh = varargin{1};
    unvoiced_thresh = varargin{2};
    Fs = 8000; %Hz
elseif nargin == 4
    clip_thresh = varargin{1};
    unvoiced_thresh = varargin{2};
    Fs = varargin{3}; %Hz
else
    error('Improper input format.');
end

% Remove DC offset
x = x - mean(x);

% Find min and max samples, account for thresholds, and center clip using cclip function
x = cclip(x, min(x)*clip_thresh, max(x)*clip_thresh);
%{
Center clips the signal x setting the lower and upper clipping thresholds from the MINVAL and MAXVAL respectively. Signal components between MINVAL and MAXVAL are 'center clipped', while components below MINVAL are shifted up and compoents above MAXVAL are shifted down. MINVAL must be negative and MAXVAL must be positive. Each elements of X is processed as follows:
If X(i) > MAXVAL, then Y(i) = X(i) ? MAXVAL;
If MINVAL < X(i) < MAXVAL, then Y(i) = 0;
If X(i) < MINVAL, then Y(i) = X(i) - MINVAL;
Motivation:
In order to use the autocorrelation function for automatic pitch detection, it is helpful to suppress the peaks due to the vocal tract transfer function. This center clipping will accomplish the suppression.
%}

% Compute the autocorrelation of the frame
Rx = xcorr(x,'coeff'); 
% Calculates the autocorrelation and also normalizes to 1
% Note that the zeroth lag of the correlation, Rx[0], is in the middle of the output sequence.

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
peaktime = index/Fs; % converting from index of sample to seconds

% Determine if the segment is unvoiced based on the 'voicing strength' (the
% ratio of the autocorrelation function at the peak pitch lag to the
% autocorrelation function at lag = 0)...
% If voicing strength is less than unvoiced_thresh, call it unvoiced and set
% pitch = 0, otherwise compute the pitch.
if peakVAL < unvoiced_thresh % segment is unvoiced
    pitch = 0;
else % segment is voiced
    pitch = 1/peaktime;
end
end
