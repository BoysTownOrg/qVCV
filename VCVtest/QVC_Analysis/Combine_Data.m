% Combine_Data - Combine Quick-VC data across participants and sessions

function Combine_Data
%DataDir='..\Data\Quick-VC';
DataDir = ['..' filesep 'Results'];
HParticipantDirs=dir([DataDir,filesep,'H*']);
NParticipantDirs=dir([DataDir,filesep,'N*']);
ParticipantDirs=[HParticipantDirs;NParticipantDirs];
Ni=length(HParticipantDirs);
Nn=length(NParticipantDirs);
Np=length(ParticipantDirs);
ID=[];
T_Combined=[];
for pk=1:Np
    id=ParticipantDirs(pk).name;
    fprintf('%2d. %s\n',pk,id)
    ParticipantDir=[DataDir,filesep,id];
    fns=dir([ParticipantDir,filesep,'*.mat']);
    Nf=length(fns);
    T_participant=[];
    for fk=2:Nf    % Skip practice
        fn=fns(fk).name;
        fprintf('\t%2d. %s\n',fk-1,fn);
        load([ParticipantDir,filesep,fn])
        T_participant=[T_participant;VCVdata];
    end
    T_Combined=[T_Combined;T_participant];
    ID=[ID;id];
end
Ns=Nf-1;
Nt=length(VCVdata);
fprintf('%d participants, %d sessions, %d trials\n',Np,Ns,Nt);
fn_mat=sprintf('%s_Combined.mat','QVC');
if (exist(fn_mat,'file')) delete(fn_mat); end
save(fn_mat,'T_Combined','ID','Np','Nn','Ni','Ns','Nt')
%------------------
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
