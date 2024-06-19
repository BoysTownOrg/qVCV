figure(2)
handles2 = guidata(gcf);
set(handles2.token_text,'String',token)
set(handles2.snr_text,'String',snr)
set(handles2.vowel_text,'String',vowel)
set(handles2.consonant_text,'String',consonant)
set(handles2.response_text,'String',' ')
set(handles2.count_text,'String',sprintf('%d/%d',vcvk,Nvcv))
set(handles2.wb2,'Position',[0 0.02 vcvk/Nvcv 0.03]);
drawnow