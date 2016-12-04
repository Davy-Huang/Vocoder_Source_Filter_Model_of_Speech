% BE491 Group ECHO PROJECT CONTENTS
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3
%
% Run Echo device overall
%   ECHO_GUI     - Code for Echo GUI
%   chvoc_main   - Generates .wav files and figures as needed for report
%                  and presentation
%   chvoc_vowel  - Examines and creates figures for the steps involved in
%                  Pitch Detection
%
% Pitch Detection
%   cclip        - Performs center clipping of input signal
%   peak         - Detects autocorrelation fundamental peak
%   pitch_detect - Pitch detection algorithm
%
% Source Generation
%   pulse_train  - Generate a discrete impulse train
%  
% Channel Vocoder
%   filt_bank    - Filter bank generator
%   chvocod_ana  - Channel vocoder analyzer
%   chvocod_syn  - Synthesizes speech waveform from pitch and band envelope
%                  signals; calls sw_source
%   chvoc_over   - Runs through entire vocoder "overall" for easy 
%                  configuration in GUI by just calling this function;
%                  calls istft, stft, voc_p, voc_p_interp


