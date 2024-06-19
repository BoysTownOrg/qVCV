function enable_buttons(state)
figure(1)
handles1 = guidata(gcf);
for k=1:14
    set(eval(sprintf('handles1.pb%d',k)),'Enable',state)
end
return