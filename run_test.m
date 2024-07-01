% participant
clear participant
figure(3)
handles3=guidata(gcf);
participants=get(handles3.participants_listbox,'String');
pk=get(handles3.participants_listbox,'Value');
participant=participants{pk};

% completed data
clear completed completed_int
completed0=dir([results_dir,filesep,participant,filesep,'*mat']);
if ~isempty(completed0)
    for k=1:length(completed0)
        temp_str=strrep(completed0(k).name,'.mat','');
        completed(k)={temp_str};
        Itemp=strfind(temp_str,'_');
        completed_int(k)=str2double(temp_str(Itemp(end)+1:end));
    end
else
    completed=[];
    completed_int=[];
end

if isempty(completed_int)
    session=0;
else
    session=max(completed_int)+1;
end

if length(completed_int)>11
    fprintf('\nParticipant %s has %d completed session! There should be a max of 11.\n',participant,length(completed_int))
    msgbox(sprintf('Participant %s has %d completed session! There should be a max of 11.',participant,length(completed_int)),'Invalid session','Warn','modal')
    return
end

if session>9
    fprintf('\nParticipant %s has completed session 10\n',participant)
    msgbox(sprintf('Participant %s has completed session 10',participant),'Invalid session','Warn','modal')
    return
end
fprintf('\nID: %s\n',participant)

% get ear
fn0=sprintf('%s_VCVinit.mat',participant);
load([Init_dir,filesep,fn0])

ear=VCVinit.ear;
fprintf('\nEar: %s\n',ear)

close all
VCVtest
