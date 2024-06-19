figure(3)
handles3=guidata(gcf);
% participant
clear participant
participants=get(handles3.participants_listbox,'String');
pk=get(handles3.participants_listbox,'Value');
participant=participants{pk};
participant_folder=[results_dir,filesep,participant];


clear session
sessions=get(handles3.sessions_listbox,'String');
if isempty(sessions)
    fprintf('\nParticipant %s does not have any data\n',participant)
    msgbox(sprintf('Participant %s does not have any data',participant),'NO Data','Warn','modal')
    return
end
sk=get(handles3.sessions_listbox,'Value');
session=sessions{sk};

clear VCVdata
if exist([participant_folder,filesep,session,'.mat'],'file')
    load([participant_folder,filesep,session,'.mat'])
else
    msgbox(sprintf('The combination of \nParticipant ID: %s\n&\nData file: %s.mat\ndoes not exist!',participant,session),'NO Data','Warn','modal')
    fprintf('\nThe combination of %s and %s.mat does not exist!\n',participant,session)
    return
end

Itemp=strfind(session,'_');
session_int=str2double(session(Itemp(end)+1:end));
msg_title=sprintf('%s Session %d Results',participant,session_int);

[score,ppta]=score_par(VCVdata,participant);

ntr=length(VCVdata);
msg1=sprintf('Correct trials: %d / %d',score,ntr);
msg2=sprintf('Percent correct: %4.1f%%',100.*(score/ntr));
msg3=sprintf('Predicted PTA: %4.1f (dB HL)',ppta);
msg=sprintf('%s\n%s\n%s\n',msg1,msg2,msg3);
msgbox(msg,msg_title,'Warn')

