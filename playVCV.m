function playVCV()

pf='Stimuli';

session=1;
if session==0
    SessionType='practice';
else    
    SessionType='test';
end

pf=[pf,filesep,SessionType];

fns = dir([pf,filesep,'*wav']);

N=length(fns);
P=randperm(N);

fns=fns(P);


for k=1:N
    fn=fns(k).name;
    fprintf('[%3d/%3d] %12s\n',k,N,fn)
    
    %
    clear I i1 i2 i3 i4
    I=strfind(fn,'_')    ;
    
    i1=I(1)+1;
    
    if (I(2)-I(1))==4        
        i2=i1+2;
        
        token=fn(i1:i2);
        vowel=token(1);
        consonant=token(2);
        
        i3=I(2)+1;
        token_number=fn(i3);
        
        i4=I(3)+1;
        if length(fn)==18
            snr=fn(i4);
        elseif length(fn)==19
            snr=fn(i4:i4+1);
        end
    elseif (I(2)-I(1))==5 % consonant is /sh/
        i2=i1+3;
        
        token=fn(i1:i2);
        vowel=token(1);
        consonant=token(2:3);
        
        i3=I(2)+1;
        token_number=fn(i3);
        
        i4=I(3)+1;
        if length(fn)==19
            snr=fn(i4);
        elseif length(fn)==20
            snr=fn(i4:i4+1);
        end
    end
    
    token_number=str2double(token_number);
    snr=str2double(snr);         
    
    [x,fs]=audioread([pf,filesep,fn]);
    
    % playback
    p=audioplayer(x,fs);
    play(p);
    playblocking(p);    
    
end



%


return

