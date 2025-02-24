figure(1)
handles1 = guidata(gcf);

response_time=toc; % response time (sec)
RT=sprintf('%.1f',response_time);

h = findobj(gcf,'Tag','response');
resp=cell2mat(get(h,'Value'));

Iresp=find(resp>0);

% turn buttons off
enable_buttons('off')


c0=[0.941176 0.941176 0.941176];

if feedback % make correct button flash green
    Ibutton=15-find(ismember(CONSONANTS,consonant)>0);
    set(eval(sprintf('handles1.pb%d',Ibutton)),'BackgroundColor','g')
    drawnow
    pause(0.5)
    set(eval(sprintf('handles1.pb%d',Ibutton)),'BackgroundColor',c0)
end

uiresume

response=CONSONANTS{Iresp};

if strcmpi(consonant,response)
    score=1;
    color_response='g';
else
    score=0;
    color_response='r';
end

% Update Experimenter GUI
figure(2)
handles2 = guidata(gcf);
set(handles2.response_text,'BackgroundColor',color_response)
set(handles2.response_text,'String',response)
set(handles2.response_time,'String',RT)
drawnow
