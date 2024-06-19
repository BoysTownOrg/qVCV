function participants=get_participants()
results_dir='Results';
participants0=dir(results_dir);
participants0(1:2)=[];
for k=1:length(participants0)
    participants(k)={participants0(k).name};
end
return
