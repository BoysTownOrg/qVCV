figure(3)
handles3=guidata(gcf);
channels=get(handles3.channels_popup,'String');
ck=get(handles3.channels_popup,'Value');
channel=channels{ck};

cal_wav='noise_0dB.wav';

[x,fs]=audioread(cal_wav);

nt=length(x);
t=(0:nt-1)./fs;
FREQ=1000;
s=cos(2.*pi.*FREQ.*t)';

s=s.*(rms(x)/rms(s));

z=zeros(size(x));
if strcmpi(channel,'Left')
    y=[s,z];
elseif strcmpi(channel,'Right')
    y=[z,s];
elseif strcmpi(channel,'Both')
    y=[s,s];
end

set(handles3.play_noise_pb,'Enable','off')
set(handles3.play_tone_pb,'Enable','off')
set(handles3.stop_playback_pb,'Enable','on')
set(handles3.calibration_status,'String','Playing')

% playback
p=audioplayer(y,fs);
play(p);
playblocking(p);

clearvars -except p

