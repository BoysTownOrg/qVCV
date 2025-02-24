close all
clear all

wrkdir=pwd;
results_dir=fullfile(wrkdir,'Results');
Init_dir=fullfile(wrkdir,'Init');
quitting=0;

VCV_HomeGUI
figure(3)
handles3=guidata(gcf);
participants_listbox_update()
set(handles3.date_edit,'String',datestr(now,'mm-dd-yyyy'))
set(handles3.participant_edit,'String',[])
set(handles3.sessions_listbox,'String',[])
set(handles3.calibration_status,'String',[])
set(handles3.stop_playback_pb,'Enable','off')

fprintf('\nWorking directory: %s\n',cd(wrkdir))
