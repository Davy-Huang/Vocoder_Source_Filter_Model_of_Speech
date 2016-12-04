% BE491 Group ECHO GUI
% Echo: A Voice Recognition and Playback System
% Davy Huang, Blake Oberfeld, Arjun Patel, Allison Ramsey, and Kate Ryan
% Lab Section B3

function RecordTemplate
%% Establishes settings to allow recording

record_dur = 5;
%Time in secs to record
%Can be set in GUI

sampRate_rec = 44100;
% Sampling rate in Hz
Fs = 8000;
%lower sampling rate

SNDREC = audiorecorder(sampRate_rec,16,1);
%creates an object to save recording data

signal_syn=[];
signal_syn_MO=[];
signal_syn_FE=[];
signal_syn_MA=[];
signal_syn_WH=[];
signal_syn_PI=[];

signal_o=[];
%proallocates signal vectors to span all workspaces

rec=0;
%creates variable to check if a recoding exists




%% Creates Figure Window

f=figure('Visible','off','color','white','Position', [50,50,1200,650]);
%Creates window set to turn off all features 
set(f,'Name','Record Template')
%Adds a name to the window


%% Adds TEXT
% sentence=uicontrol('Style','text',...
%     'BackgroundColor','green', ...
%     'FontSize',30,...
%     'Units','normalized',...
%     'Position',[.1, .9, .8, .1],...
%     'String', 'The empty flask stood on the tin tray');
% %create txt to show sentence to be read



Info=uicontrol('Style','text',...
    'BackgroundColor','white', ...
    'Units','normalized',...
    'Position',[.60, .15, .4, .05],...
    'String', '');
%create txt to pass info to user
%left blank to begin



Label=uicontrol('Style','text',...
    'BackgroundColor','white', ...
    'Units','normalized',...
    'Position',[.1, .2, .05, .025],...
    'String', 'Record Time');
%create txt to label the recording time input


%% Adds the BUTTONS to the GUI


RecordButton=uicontrol('Style','pushbutton',...
    'String','Record',...
    'Units','normalized',...
    'Position',[.05,.15,.05,.05],...
    'Callback',@Record);
%creates a button that start the RECORDING


PlaybackButton=uicontrol('Style','pushbutton',...
    'String','Play Unaltered',...
    'Units','normalized',...
    'Position',[.15,.15,.075,.05],...
    'Callback',@PlaybackO);
%creates a button that will start the PLAYBACK Unaltered


PlaybackButton=uicontrol('Style','pushbutton',...
    'String','Play Original',...
    'Units','normalized',...
    'Position',[.225,.15,.075,.05],...
    'Callback',@Playback);
%creates a button that will start the PLAYBACK ORIGINAL



PlaybackButton=uicontrol('Style','pushbutton',...
    'String','Play Monotone',...
    'Units','normalized',...
    'Position',[.30,.15,.075,.05],...
    'Callback',@PlaybackMono);
%creates a button that will start the PLAYBACK MONOTONE

PlaybackButton=uicontrol('Style','pushbutton',...
    'String','Play Whisper',...
    'Units','normalized',...
    'Position',[.375,.15,.075,.05],...
    'Callback',@PlaybackWhisp);
%creates a button that will start the PAYBACK WHISPER

PlaybackButton=uicontrol('Style','pushbutton',...
    'String','Play Male',...
    'Units','normalized',...
    'Position',[.45,.15,.075,.05],...
    'Callback',@PlaybackMale);
%creates a button that will start the PLAYBACK Male

PlaybackButton=uicontrol('Style','pushbutton',...
    'String','Play Female',...
    'Units','normalized',...
    'Position',[.525,.15,.075,.05],...
    'Callback',@PlaybackFemale);
%creates a button that will start the PLAYBACK Female

PlaybackButton=uicontrol('Style','pushbutton',...
    'String','Play Pitchless',...
    'Units','normalized',...
    'Position',[.6,.15,.075,.05],...
    'Callback',@PlaybackPitchless);
%creates a button that will start the PLAYBACK PITCHLESS


%% Adds NUMBER INPUT to set recording time

RecordTime=uicontrol('Style','edit',...
    'Units','normalized',...
    'Position',[.10,.15,.05,.05],...
    'String',num2str(record_dur));
%create input string to allow input of recoding time
%units are seconds
%% Prealocates locations


%Freq plot 2

TR=[.55,.65,.3,.25];
subplot('Position',TR)
axis off


%Time plot 2

BR=[.55,.275,.3,.25];
subplot('Position',BR)
axis off

%Freq plot 1

TL=[.05,.65,.3,.25];
subplot('Position',TL)
axis off

%Time plot 1

BL=[.05,.275,.3,.25];
subplot('Position',BL)
axis off









%% Makes GUI visible
set(f,'Visible','on')
%Turns on all features. This allows the buttons/text to be loaded quickly

%% Sub functions
%% RECORDING SUBFUNCTION
function Record(hObject, eventdata)
    record_dur =str2double(get(RecordTime,'String'));
    %gets length of recording from GUI
    
    if record_dur<=0 
        %ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Record time must be greater than zero')
        %if else used to tell to select a recoding time greater than 0
    else
        %NO ERROR in order of steps
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Starting Recoding')
        %informs the user recoding is started
        
        %pause allows person to prepare after clicking the button
        set(Info, 'String', 'RECORDING...')
        
        recordblocking(SNDREC, record_dur);
        %Recording is done during this step
        
        set(Info, 'String', 'Recoding Ended')
        %informs the user the recoding has ended
        
        
        set(Info, 'String', 'proccesing...')
        snd.data = getaudiodata(SNDREC);
        signal_o = resample(snd.data, 2, 11,100);
        
        
        
        D = 10;
        N = 18;
        [signal_syn, Fs] = chvoc_over(signal_o, D, N, Fs, 'OR');
        [signal_syn_MO, Fs] = chvoc_over(signal_o, D, N, Fs, 'MO');
        [signal_syn_FE, Fs] = chvoc_over(signal_o, D, N, Fs, 'FE');
        [signal_syn_MA, Fs] = chvoc_over(signal_o, D, N, Fs, 'MA');
        [signal_syn_WH, Fs] = chvoc_over(signal_o, D, N, Fs, 'WH');
        [signal_syn_PI, Fs] = chvoc_over(signal_o, D, N, Fs, 'PI');
        
        %Time plot
        subplot('Position',TL)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        plot((0:length(signal_syn)-1)/8000, signal_syn, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        hold off
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.05,.03,.4,.1]);
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 15)

        
        
        rec=1;
        %Remembers there is data to playback
        set(Info, 'String', 'Done')
        pause(0.5)
        set(Info, 'String', 'Try Playback')
        
        %Frequency plot
        subplot('Position',BL)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar

        axis xy
        ylim([0 Fs/2])
        set(gca, 'FontSize', 10)

        xlabel('Time (s)', 'FontSize', 15)

        ylabel('Frequency (Hz)', 'FontSize', 15)

        title('Spectrogram for Synthesized "Original" ','FontSize', 15)

        

    
    end
end

%% Playback subfunction
%% PLAYBACK NORMAL SUBFUNCTION
%Subfuction utilizes progonal object
%There is no major issue with playback here
function Playback(hObject,eventdata)
    if rec~=1 
        %ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Data must be recorded before playback')
        %if else used to tell user to record first
    else
        %NO ERROR
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        soundsc(signal_syn)
        set(Info, 'String', 'Playback is done')
        
        %plots
        
        %time plot
        subplot('Position',TR)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        
        plot((0:length(signal_syn)-1)/8000, signal_syn, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.55,.03,.4,.1]);
        
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 17)
        hold off
        %Frequency Plot
        subplot('Position',BR)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar
        
        axis xy

        xlabel('Time (s)')

        ylabel('Frequency (Hz)')

        title('Spectrogram for "Original" Utterrance Synthesized in Channel Vocoder','FontSize', 15)

        ylim([0 Fs/2])
    end
end

%% PLAYBACK Orginal SUBFUNCTION
%Subfuction utilizes progonal object
%There is no major issue with playback here
function PlaybackO(hObject,eventdata)
    if rec~=1 
        %ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Data must be recorded before playback')
        %if else used to tell user to record first
    else
        %NO ERROR
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        soundsc(signal_o)
        set(Info, 'String', 'Playback is done')
        
        %plots
        
        %time plot
        subplot('Position',TR)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        plot((0:length(signal_syn)-1)/8000, signal_syn, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.55,.03,.4,.1]);
        
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 17)

        hold off
        %Frequency Plot
        subplot('Position',BR)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar
        axis xy
        set(gca, 'FontSize', 10)

        xlabel('Time (s)')

        ylabel('Frequency (Hz)')

        title('Spectrogram for Original Utterrance Synthesized in Channel Vocoder','FontSize', 15)

        ylim([0 Fs/2])
    end
end

%% PLAYBACK MONOTONE SUBFUNCTION
function PlaybackMono(hObject,eventdata)
    if rec~=1 
        %ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Data must be recorded before playback')
        %if else used to tell user to record first
    else
        %NO ERROR
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        soundsc(signal_syn_MO)
        set(Info, 'String', 'Playback is done')
        
        %plots
        
        %time plot
        subplot('Position',TR)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        plot((0:length(signal_syn_MO)-1)/8000, signal_syn_MO, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.55,.03,.4,.1]);
        
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 15)
        
        hold off
        %Frequency Plot
        subplot('Position',BR)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn_MO,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar
        
        axis xy
        set(gca, 'FontSize', 10)

        xlabel('Time (s)')

        ylabel('Frequency (Hz)')

        title('Spectrogram for "Monotone" Utterrance Synthesized in Channel Vocoder','FontSize', 15)

        ylim([0 Fs/2])
    end
    
        
end

function PlaybackWhisp(hObject,eventdata)
    if rec~=1
        % ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Data must be recorded before playback')
        %if else used to tell user to record first
    else
        %NO ERROR
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        sound(signal_syn_WH*0.6)
        set(Info, 'String', 'Playback is done')
        
        %plots
        
        %time plot
        subplot('Position',TR)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        plot((0:length(signal_syn_WH)-1)/8000, signal_syn_WH, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.55,.03,.4,.1]);
        
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 15)
        
        hold off
        %Frequency Plot
        subplot('Position',BR)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn_WH,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar
        
        axis xy

        xlabel('Time (s)')

        ylabel('Frequency (Hz)')

        title('Spectrogram for "Whisper" Utterrance Synthesized in Channel Vocoder','FontSize', 15)

        ylim([0 Fs/2])
    end   
end

function PlaybackMale(hObject,eventdata)
    if rec~=1
        % ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Data must be recorded before playback')
        %if else used to tell user to record first
    else
        %NO ERROR
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        soundsc(signal_syn_MA)
        set(Info, 'String', 'Playback is done')
        
        %plots
        
        %time plot
        subplot('Position',TR)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        plot((0:length(signal_syn_MA)-1)/8000, signal_syn_MA, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.55,.03,.4,.1]);
        
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 15)
        
        hold off
        %Frequency Plot
        subplot('Position',BR)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn_MA,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar
        
        axis xy

        xlabel('Time (s)')

        ylabel('Frequency (Hz)')

        title('Spectrogram for "Male" Utterrance Synthesized in Channel Vocoder','FontSize', 15)

        ylim([0 Fs/2])
    end   
end


function PlaybackFemale(hObject,eventdata)
    if rec~=1
        % ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Data must be recorded before playback')
        %if else used to tell user to record first
    else
        %NO ERROR
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        soundsc(signal_syn_FE)
        set(Info, 'String', 'Playback is done')
        
        subplot('Position',TR)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        plot((0:length(signal_syn_FE)-1)/8000, signal_syn_FE, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.55,.03,.4,.1]);
        
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 15)
        
        hold off
        %Frequency Plot
        subplot('Position',BR)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn_FE,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar
        
        axis xy
        set(gca, 'FontSize', 10)

        xlabel('Time (s)')

        ylabel('Frequency (Hz)')

        title('Spectrogram for "Female" Utterrance Synthesized in Channel Vocoder','FontSize', 15)

        ylim([0 Fs/2])
    end   
end

function PlaybackPitchless(hObject,eventdata)
    if rec~=1
        % ERROR CHECKING
        
        set(Info, 'BackgroundColor','red')
        %Background changed to red to emphasize error
        set(Info, 'String', 'Data must be recorded before playback')
        %if else used to tell user to record first
    else
        %NO ERROR
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        
        set(Info, 'BackgroundColor','white')
        %Background changed back
        set(Info, 'String', 'Recoding is being played back')
        sound(signal_syn_PI*0.6)
        set(Info, 'String', 'Playback is done')
        
        %plots
        
        %time plot
        subplot('Position',TR)
        plot((0:length(signal_o)-1)/8000, signal_o/norm(signal_o,inf), 'b-', 'Linewidth', 2)
        hold on
        
        plot((0:length(signal_syn_PI)-1)/8000, signal_syn_PI, 'Color', [0.302 0.745 0.933], 'Linewidth', 2)
        
        legend('Recorded', 'Synthesized in Channel Vocoder',...
            'Location',[.55,.03,.4,.1]);
        
        set(gca, 'FontSize', 10)
        xlabel('Time (s)', 'FontSize', 15)
        ylabel('Normalized Amplitude', 'FontSize', 15)
        str = sprintf('Time Domain of Recorded Utterance:\nNormalized Amplitude v. Time');
        title(str,'FontSize', 15)
        
        hold off
        %Frequency Plot
        subplot('Position',BR)

        [S_syn,F_syn,T_syn] = spectrogram(signal_syn_PI,2^10,2^9,[],Fs);
        imagesc(T_syn,F_syn,20*log10(abs(S_syn)),[-126 34])
        colorbar
        
        axis xy

        xlabel('Time (s)')

        ylabel('Frequency (Hz)')

        title('Spectrogram for "Pitchless" Utterrance Synthesized in Channel Vocoder','FontSize', 15)

        ylim([0 Fs/2])
    end   
end
end
