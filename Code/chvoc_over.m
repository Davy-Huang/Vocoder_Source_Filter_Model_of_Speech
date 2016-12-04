% BE491 Group Digital Channel Vocoder over for simple call from GUI
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

function [signal_syn, Fs, p] = chvoc_over(signal_o, D, N, varargin)
%% chvoc_over generates a NORMALIZED signal synthesized in the channel vocoder, 
%  as well as returning the Fs and the pitch vector
% Inputs include:
% varargin{1} can be used to specify the sampling frequency, default 8kHz
% varargin{2} can also be used as a string input to change the voice:
    % ORIGINAL: Leave pitch vector (p) as is; this is default
    %  p = p;
    % FEMALE: Multiply pitch vector (p) by a factor of 5/3
    %  p = p * 5/3;
    % MALE:   Multiply pitch vector (p) by a factor of 3/4
    %  p = p * 3/4;
    % WHISPER: Set pitch vector (p) to zeros
    %  p = zeros(1,length(p));
    % MONOTONE: Set pitch vector (p) to contsant value (eg. 100Hz)
    %  p= ones(1,length(p)).*100;
    
%% Address inputs
% Change signal length to standard
signal_o = [signal_o; zeros(ceil(size(signal_o,1)/D)*D-size(signal_o,1),1)];
% Fs
if nargin < 4
    Fs = 8E3; %Hz
else
    Fs = varargin{1};
end
% type
if nargin < 5
    type = 'OR';
elseif nargin == 5 && ischar(varargin{2})
    type = upper(varargin{2}(1:2));
else
    error('Incorrect formatting of chvoc_over inputs.\n')
end
%% Run utterence through the channel vocoder analyzer
[y,p] = chvocod_ana(signal_o, D, N, Fs);
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

%% Run the pitch vector through the channel vocoder synthesizer within each type
% signal_syn = chvocod_syn(y,p,D);  
    % CHVOCOD_SYN  Synthesizes speech waveform from pitch and band envelope signals
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
%% TYPE
if type == 'MO'
    % MONOTONE: Set pitch vector (p) to contsant value (eg. 100Hz)
    p= ones(1,length(p)).*100;
    % Run the pitch vector through the channel vocoder synthesizer
    signal_syn = chvocod_syn(y, p, D);
    signal_syn = signal_syn/norm(signal_syn, inf);
elseif type == 'FE'
    % FEMALE: Multiply pitch vector (p) by a factor of 5/3
    p = p * 5/3;
    % Run the pitch vector through the channel vocoder synthesizer
    signal_syn = chvocod_syn(y, p, D);
    signal_syn = voc_p(signal_o, 3/5);
    signal_syn = resample(signal_syn, 3, 5);
    signal_syn = signal_syn/norm(signal_syn, inf);
elseif type == 'MA'
    % MALE:   Multiply pitch vector (p) by a factor of 3/4
    p = p * 3/4;
    % Run the pitch vector through the channel vocoder synthesizer
    signal_syn = chvocod_syn(y, p, D);
    signal_syn = voc_p(signal_o, 4/3);
    signal_syn = resample(signal_syn, 4,3);
    signal_syn = signal_syn/norm(signal_syn, inf);
elseif type == 'PI'
    % PITCHLESS: Set pitch vector (p) to zeros
    p = zeros(1,length(p));
    % Run the pitch vector through the channel vocoder synthesizer
    signal_syn = chvocod_syn(y, p, D);
    signal_syn = signal_syn/norm(signal_syn, inf)*0.3;
elseif type == 'WH'
    % WHISPER: Set pitch vector (p) to whitenoise (an aperiodic signal with 
    % random frequencies of equal intensities)
    p = sqrt(2)*randn(length(p),1);
    % Run the pitch vector through the channel vocoder synthesizer
    signal_syn = chvocod_syn(y, p, D);
    signal_syn = signal_syn/norm(signal_syn, inf)*0.3;
else
    % ORIGINAL: Leave pitch vector (p) as is
    %  p = p;
    % Run the pitch vector through the channel vocoder synthesizer
    signal_syn = chvocod_syn(y, p, D);
    signal_syn = mean([signal_o/norm(signal_o, inf) signal_syn/norm(signal_syn, inf)],2);
end

% soundsc(signal_syn);