figure(3)
handles3=guidata(gcf);
participant=get(handles3.participant_edit,'String');
date1=get(handles3.date_edit,'String');
ears=get(handles3.ear_popup,'String');
ek=get(handles3.ear_popup,'Value');
ear=ears{ek};

participants=get_participants();

results_dir='Results';

% validate id
if isempty(participant)
    fprintf('Please enter Participant ID\n')
    msgbox('Please enter Participant ID','Invalid participant ID','Warn','modal')
    return
end
if length(participant)~=5 
    fprintf('Participant ID must be 5 characters long, like NH123, HL234, HA345, or HP456\n')
    msgbox('Participant ID must be 5 characters long, like NH123, HL234, HA345, or HP456','Invalid participant ID','Warn','modal')
    return
end
if ~(strcmp(participant(1:2),'NH') || strcmp(participant(1:2),'HL')... 
        || strcmp(participant(1:2),'HA') || strcmp(participant(1:2),'HP')) 
    fprintf('Participant ID has to be of the form NH123, HL234, HA345, or HP456\n')
    msgbox('Participant ID has to be of the form NH123, HL234, HA345, or HP456','Invalid participant ID','Warn','modal')
    return
end
if ismember(participant,participants)
    fprintf('Participant ID already exists\n')
    msgbox('Participant ID already exists','Invalid participant ID','Warn','modal')
    return
end

% validate date
if isempty(date1)
    fprintf('Please enter Test date\n')
    msgbox('Please enter Test date','Invalid test date','Warn','modal')
    return
end


fprintf('\nNew Participant:\n')
fprintf('\n%10s: %s\n','ID',participant)
fprintf('%10s: %s\n','Ear',ear)
fprintf('%10s: %s\n','Test date',date1)


len=length(participants);
participants(len+1)={participant};

mkdir([results_dir,filesep,participant]);

participants_listbox_update()

VCVinit.participant=participant;
VCVinit.date=date1;
VCVinit.ear=ear;

fnsv0=sprintf('%s_VCVinit.mat',participant);
save(fnsv0,'VCVinit')

movefile(fnsv0,Init_dir);
