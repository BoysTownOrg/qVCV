figure(3)
handles3=guidata(gcf);
participants=get(handles3.participants_listbox,'String');
pk=get(handles3.participants_listbox,'Value');
participant=participants{pk};

clear completed0 completed
completed0=dir([results_dir,filesep,participant,filesep,'*mat']);
if ~isempty(completed0)
    for k=1:length(completed0)
        completed(k)={strrep(completed0(k).name,'.mat','')};
    end
else
    completed=[];
end

set(handles3.sessions_listbox,'String',completed)
