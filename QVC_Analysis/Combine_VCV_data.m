% Combine_qVCV_data - Combine VCV data across participants and sessions

function Combine_VCV_data
DataDir = fullfile('..','Results');
if (~exist(DataDir,'dir'))
    DataDir=fullfile('..','Data','qVCV');
end
if (~exist(DataDir,'dir'))
    error('DataDir not found');
end
HParticipantDirs=dir([DataDir,filesep,'H*']);
NParticipantDirs=dir([DataDir,filesep,'N*']);
ParticipantDirs=[HParticipantDirs;NParticipantDirs];
Np=length(ParticipantDirs);
ID=[];
T_Combined=[];
IDa=[];
Ta_Combined=[];
Nc=0; % number of completed protocols
Nu=[0 0]; % number unaided (NH,HL)
Na=[0 0]; % number aided (lab,personal)
cat=zeros(Np,1);
ses=zeros(Np,1);
for pk=1:Np
    id=ParticipantDirs(pk).name;
    fprintf('%2d. %s\n',pk,id)
    ParticipantDir=[DataDir,filesep,id];
    fns=dir([ParticipantDir,filesep,'*.mat']);
    Nf=length(fns);
    if (Nf>1) % at least one test sessions ???
        T_participant=[];
        for fk=2:Nf    % skip practice
            fn=fns(fk).name;
            fprintf('\t%2d. %s\n',fk-1,fn);
            pn=fullfile(ParticipantDir,fn);
            load(pn,'VCVdata')
            T_participant=[T_participant;VCVdata];
        end
        if (Nf>4)
            T_participant=[T_participant([1 3],:) T_participant([2 4],:)];
        end
        if (Nf>2)
            ses(pk)=2;
        else
            ses(pk)=1;
        end
        T_Combined=[T_Combined;T_participant];
        ID=[ID;id];
        if (contains(id,'NH')), cat(pk)=1; end
        if (contains(id,'HL')), cat(pk)=2; end
        if (contains(id,'HA')), cat(pk)=3; end
        if (contains(id,'HP')), cat(pk)=4; end
    end
end
[Ns,Nt]=size(T_Combined);
Np=sum(cat>0);
Nu=[sum(cat==1) sum(cat==2)];
Na=[sum(cat==3) sum(cat==4)];
fprintf('%d sessions, %d trials\n',Ns,Nt);
fprintf('participants(%d): unaided=%d+%d aided=%d+%d\n',Np,Nu,Na);
% eliminate participants with no sessions
cat=cat(ses>0);
ses=ses(ses>0);
Nc=length(cat);
idx=[1;1+cumsum(ses(1:(end-1)))];
% save data
fn_mat=sprintf('QVC_Combined.mat');
if (exist(fn_mat,'file')), delete(fn_mat); end
save(fn_mat,'T_Combined','ID','Nu','Ns','Nt','cat','ses','idx')
%------------------
return
