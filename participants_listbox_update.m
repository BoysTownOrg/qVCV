function participants_listbox_update()
figure(3)
handles3=guidata(gcf);
participants=get_participants();
set(handles3.participants_listbox,'String',participants)
return

