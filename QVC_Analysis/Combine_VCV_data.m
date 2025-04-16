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
Ni=0; % number impaired
Nn=0; % number normal
Nu=[0 0]; % number unaided (NH,HL)
Na=[0 0]; % number aided (lab,personal)
for pk=1:Np
    id=ParticipantDirs(pk).name;
    fprintf('%2d. %s\n',pk,id)
    ParticipantDir=[DataDir,filesep,id];
    fns=dir([ParticipantDir,filesep,'*.mat']);
    Nf=length(fns);
    T_participant=[];
    %if (Nf<5) continue; end
    for fk=2:Nf    % Skip practice
        fn=fns(fk).name;
        fprintf('\t%2d. %s\n',fk-1,fn);
        load([ParticipantDir,filesep,fn])
        T_participant=[T_participant;VCVdata];
    end
    if (Nf>4)
        %T_participant=[T_participant([1 2],:) T_participant([3 4],:)];
        T_participant=[T_participant([1 3],:) T_participant([2 4],:)];
        T_Combined=[T_Combined;T_participant];
        ID=[ID;id];
        Nc=Nc+1;
        if (id(1)=='H') Nu(1)=Nu(1)+1; end
        if (id(1)=='N') Nu(2)=Nu(2)+1; end
    elseif (Nf>0)
        Ta_Combined=[Ta_Combined;T_participant];
        IDa=[IDa;id];
        if (id(2)=='A') Na(1)=Na(1)+1; end
        if (id(2)=='P') Na(2)=Na(2)+1; end
    end
end
[Ns,Nt]=size(T_participant);
Np=sum(Nu);Ni=Nu(1);Nn=Nu(2);
fprintf('%d sessions, %d trials\n',Ns,Nt);
fprintf('participants(%d): unaided=%d+%d aided=%d+%d\n',Np,Nu,Na);
fn_mat=sprintf('QVC_Combined.mat');
if (exist(fn_mat,'file')) delete(fn_mat); end
save(fn_mat,'T_Combined','ID','Nu','Ns','Nt','Ta_Combined','IDa','Na')
%------------------
return
for sk=1:Ns
    fn_xls=sprintf('QVC_Session%d.xlsx',sk);
    if (exist(fn_xls,'file')) delete(fn_xls); end
    for pk=1:Np
        n=sk+(pk-1)*Ns;
        tbt=transpose(T_Combined(n,:));
        V=char(tbt.vowel);
        C=char(tbt.consonant);
        R=char(tbt.response);
        S=floor(char(tbt.score));
        T=table(V,C,R,S);
        N=ID(pk,:);
        writetable(T,fn_xls,'Sheet',N)
    end
end
return
