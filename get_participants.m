function participants=get_participants()
results_dir='Results';
participants0=dir(results_dir);
for k=1:length(participants0)
    if (participants0(1).name(1)=='.') % remove system files
        participants0(1)=[]; 
    end
end
for k=1:length(participants0)
    participants(k)={participants0(k).name};
end
return
