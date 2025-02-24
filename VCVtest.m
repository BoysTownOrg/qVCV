clearvars -except participant ear session results_dir Init_dir quitting test
if (~exist('session','var')) fprintf('Run ConsonantTest...\n'); return; end
if (contains(participant,'NH')||contains(participant,'HL'))
    prct=0;         % VCV both instances for LONG practive session
    inst=[0 0];     % VCV both instances for LONG test session
    test.type='LONG';
else
    prct=1;         % VCV first instance for SHORT practice session
    inst=0;         % VCV both instances for SHORT test session
    test.type='SHORT';
end
reps=5;         % VCV repetitions per test session
nses=length(inst); % number of test sessions

CONSONANTS={'other','z','v','t','sh','s','p','n','m','k','g','f','d','b'};
stimulus_folder='Stimuli';
participant_folder=fullfile(results_dir,participant);

if session==0
    SessionType='practice';
    feedback=1;
    instance=prct;
    nrep=1;
elseif session<=nses
    SessionType='test';
    feedback=0;
    instance=inst(session);
    nrep=reps;
else
    fprintf('Session=%d completed!\n',nses);
    clear all
    close all
    return
end
fprintf('\nRunning VCV test\n\tparticipant id:%s\n\tsession: %d - %s\n',...
    participant,session,SessionType)

stimulus_folder=fullfile(stimulus_folder,SessionType);
fns = dir(fullfile(stimulus_folder,'*wav'));
Nvcv=length(fns);
vcv=zeros(Nvcv,1);
for k=1:Nvcv
    if(strfind(fns(k).name,'_1_')) vcv(k)=1; end
    if(strfind(fns(k).name,'_2_')) vcv(k)=2; end
end
if (instance==1)     % select VCV1 only
    fns=fns(vcv==1);
elseif (instance==2) % select VCV2 only
    fns=fns(vcv==2);
end

Nvcv=length(fns);
P=[];
for k=1:nrep
    P=[P randperm(Nvcv)];
end
Nvcv=length(P);

close all

VCV_ListenerGUI

VCV_ExperimenterGUI
figure(2)
handles2=guidata(gcf);
set(handles2.continue_pb,'Enable','off')
set(handles2.status_text,'String','')

for vcvk=1:Nvcv
    if quitting==1
        quitting=0;
        clear all
        close all
        return
    end

    fn=deblank(fns(P(vcvk)).name);
    fprintf('[%3d/%3d] %12s\n',vcvk,Nvcv,fn)
    
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
            
    % Update Experimenter GUI
    VCV_ExperimenterGUI_Update
    
    [x,fs]=audioread(fullfile(stimulus_folder,fn));    
    z=zeros(size(x));
    if strcmpi(ear,'Left')
        y=[x,z];
    elseif strcmpi(ear,'Right')
        y=[z,x];
    elseif strcmpi(ear,'Both')
        y=[x,x];
    end

    if vcvk==1
        hb=msgbox(sprintf('Click OK to begin %s session %d (%s) for %s',...
            test.type,session,upper(SessionType),participant),'Ready?');
        waitfor(hb)
        if (~exist('vcvk','var')) quit; end
    end
    
    figure(1)
    handles1 = guidata(gcf);
    set(handles1.listener_text,'String','Please listen')

    % playback
    p=audioplayer(y,fs);
    play(p);
    playblocking(p);
    
    % turn buttons on
    enable_buttons('on')
    figure(1)
    handles1 = guidata(gcf);
%     waitbar(vcvk/Nvcv,handles1.wb1)
    set(handles1.wb1,'Position',[0 0.02 vcvk/Nvcv 0.04]);
    set(handles1.listener_text,'String','Make a selection')
    tic
    uiwait
    if (~exist('vcvk','var')) return; end
    
    VCVdata(vcvk).token=token;
    VCVdata(vcvk).token_number=token_number;
    VCVdata(vcvk).snr=snr;
    VCVdata(vcvk).vowel=vowel;
    VCVdata(vcvk).consonant=consonant;
    VCVdata(vcvk).response=response;
    VCVdata(vcvk).response_time=response_time;
    VCVdata(vcvk).score=score;
    SCORE(vcvk)=score;

end

percent_correct=100*sum(SCORE)/Nvcv;

fn0=sprintf('%s_VCVinit.mat',participant);
load(fullfile(Init_dir,fn0))
testdate=VCVinit.date;
ear=VCVinit.ear;

% save data as .mat file
fnsv=sprintf('%s_VCVresults_Session_%d.mat',participant,session);
save(fullfile(participant_folder,fnsv),'VCVdata','testdate','ear')
fprintf('\nData saved\n\tFilename: %s\n',fullfile(participant_folder,fnsv))

% save data as .xls file
xlsfn=sprintf('%s_VCVdata.xls',participant);
xlsfn=fullfile(participant_folder,xlsfn);
Sheet=sprintf('Session %2d',session);
vcv2xls(xlsfn,Sheet,VCVdata)


if session>=nses
    figure(2)
    handles2 = guidata(gcf);
    set(handles2.status_text,'String',sprintf('Session %d completed\nScore = %2.1f%%\nDONE!',session,percent_correct))
    fprintf('\nSession %d completed\nDONE!\n',session)
    figure(1)
    handles1 = guidata(gcf);
    set(handles1.listener_text,'String','You are DONE! Thanks!')
else
    figure(2)
    handles2 = guidata(gcf);
    set(handles2.continue_pb,'Enable','on')
    set(handles2.status_text,'String',sprintf('Session %d completed\nScore = %2.1f%%\nContinue?',session,percent_correct))
    fprintf('\nSession %d completed\n',session)
end

