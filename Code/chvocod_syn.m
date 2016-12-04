% BE491 Group Digital Channel Vocoder Synthesizer
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

function y = chvocod_syn(band_envelopes, pitch, R, varargin)
%CHVOCOD_SYN  Synthesizes speech waveform from pitch and band envelope signals
%   OUT = CHVOCOD_SYN(BAND_ENVELOPES,PITCH,UPSAMPLE) synthesizes the speech
%   signal encoded by a channel vocoder with frequency band envelopes specified
%   by matrix BAND_ENVELOPES and pitch values specified by vector PITCH. The
%   signal is upsampled by the value specified in UPSAMPLE. An optional input,
%   varargin/Fs is the sampling frequency, where the default is 8kHz.
%
%   Each column of BAND_ENVELOPES contains all frame information within each
%   frequency band. Each row of BAND_ENVELOPES contains all frequency band
%   information within each data frame. PITCH contains the pitch information for
%   each data frame.
%% Initialize variables
% Set sampling frequency
if nargin == 4
    Fs = varargin{1};
elseif nargin == 3
    Fs = 8000; % Hz
else
    error('You must enter 3 or 4 input arguments.');
end

% Length of each frame in samples
frame_length = R;
% Determine number of bands from input matrix
N = size(band_envelopes,2);  
% Compute FIR coefficients for the filter bank
L = 65;  % length of each filter
bank = filt_bank(N,L);

% Generate a voiced source signal using pulse_train
src = sw_source(pitch,Fs,frame_length);

% Compute length of source signal
M = length(src);

% Preallocate output matrix for efficiency
ybands = zeros(M,N);

% In loop, process each band:
for i = 1:N
    % Interpolate (upsample) each decimated band envelope
    % and replace any negative values with zeros
    xint = interp(band_envelopes(:,i),R);
    xint(xint<0) = 0;

    % Multiply with source, trimming the interpolated signal to
    % match pulse train length, M.
    yint = xint(1:M) .* src;

    % Apply bandpass filter . . .
    ybands(:,i) = fftfilt(bank(:,i),yint);
end

% Add up the output of all of the bands to generate result
y = sum(ybands,2);
y(y<0) = y(y<0)/abs(min(y)) * max(y);
