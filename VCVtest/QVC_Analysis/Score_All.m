% Score_All - Compute SCORE & PPTA for participants and sessions

function Score_All
%DataDir='..\Data\Quick-VC';
DataDir = ['..' filesep 'Results'];
[ParticipantDirs,Nx]=Combine_Prefix(DataDir,{'NH*','HL*'});
[score,ppta]=Score_Participants(DataDir,ParticipantDirs);
[Np,Ns]=size(score);
fprintf('%d participants, %d sessions,N(NH,HL)=%d,%d\n',Np,Ns,Nx);
scatter_plot('score',score,1);
scatter_plot('ppta',ppta,2);
kn=1:Nx(1);
nhs=mean(mean(score(kn,:)));
mad=mean(abs(ppta(:,1)-ppta(:,2)));
fprintf('NH%%=%.0f  PPTA_MAD=%.1f dB\n',nhs,mad);
end % return

function [ParticipantDirs,Nx]=Combine_Prefix(DataDir,prfx)
Nx=zeros(size(prfx));
ParticipantDirs=[];
for k=1:length(Nx)
    kParticipantDirs=dir([DataDir,filesep,char(prfx{k})]);
    ParticipantDirs=[ParticipantDirs;kParticipantDirs];
    Nx(k)=length(kParticipantDirs);
end
end % return

function [score,ppta]=Score_Participants(DataDir,ParticipantDirs)
Np=length(ParticipantDirs);
for pk=1:Np
    id=ParticipantDirs(pk).name;
    ParticipantDir=[DataDir,filesep,id];
    fns=dir([ParticipantDir,filesep,'*.mat']);
    Nf=length(fns);
    T_participant=[];
    for fk=2:Nf    % Skip practice
        fn=fns(fk).name;
        load([ParticipantDir,filesep,fn],'VCVdata')
        T_participant=[T_participant;VCVdata];
    end
    Nt=length(VCVdata);
    Ns=Nf-1;
    fprintf('%2d. %s: %d sessions %d trials\n',pk,id,Ns,Nt)
    [s,p]=score_par(T_participant,id);
    if (pk==1)
        score=zeros(Np,Ns);
        ppta =zeros(Np,Ns);
    end
    score(pk,:)=s;
    ppta(pk,:)=p;
    for sk=1:Ns
        fprintf('    %2d. score=%3d ppta=%3.1f\n',sk,s(sk),p(sk));
    end
end
end % return

%========================================

function [score,ppta]=score_par(T_Combined,ID)
[ts,Nt]=size(T_Combined);
Np=size(ID,1);
Ns=ts/Np;
%fprintf('%d participants, %d sessions, %d trials\n',Np,Ns,Nt);
load('regress_pta','B','C','ca')
uvwl={'a'};
ucns={'b','d','g','k','n','s','sh','t','v','z'};
ursp={'b','d','g','k','n','s','sh','t','v','z','other'};
ilst=1;
%
score=zeros(Np,Ns);
ppta=zeros(Np,Ns);
ids=cell(Nt,1);
vwl=cell(Nt,1);
cns=cell(Nt,1);
rsp=cell(Nt,1);
for pk=1:Np
    T_Participant=T_Combined((1:Ns)+(pk-1)*Ns,:);
    uids={ID(pk,:)};
    for sk=1:Ns
        tbt=transpose(T_Participant(sk,:));
        S=floor(char(tbt.score));
        score(pk,sk)=sum(S);
        for tk=1:Nt
            ids{tk}=ID(pk,:);
            vwl{tk}=tbt(tk).vowel;
            cns{tk}=tbt(tk).consonant;
            rsp{tk}=tbt(tk).response;
        end
        ccms=compute_ccms(ilst,ids,vwl,cns,rsp,uids,uvwl,ucns,ursp);
        ppta(pk,sk)=predict_pta(ccms,ca,B,C);
    end
end
end %return

%========================================

function scatter_plot(var,v,fig)
figure(fig);clf;
v1=v(:,1);
v2=v(:,2);
plot(v1,v2,'bo')
xlabel([var ' 1']);
ylabel([var ' 2']);
rho=corr(v1,v2);
vmn=min(min(v))-3;
vmx=max(max(v))+3;
axis([vmn vmx vmn vmx])
x=(vmn+0.7*(vmx-vmn));
y=(vmn+0.1*(vmx-vmn));
text(x,y,sprintf('R=%.2f',rho));
end % return

%========================================

function ccms=compute_ccms(ilst,ids,vwl,cns,rsp,uids,uvwl,ucns,ursp)
ni=length(ilst);
nv=1;
ncns=length(ucns);
nrsp=length(ursp);
ccms=zeros(ni,ncns,nrsp,nv);
for k=1:ni
    kk=ilst(k);
    ci=cmp(ids,uids,kk);
    for i=1:nv
        for j=1:ncns
            cv=cmp(vwl,uvwl,i);
            cc=cmp(cns,ucns,j);
            %-------------------------
            for r=1:nrsp
                cr=cmp(rsp,ursp,r);
                jj=cv&cc&cr&ci;
                nr=sum(jj);
                ccms(k,j,r,i)=nr;
            end
        end
    end
end
%ccms=squeeze(ccms);
end %return

function match=cmp(str,ustr,i)
n=length(str);
match=ones(n,1);
for k=1:n
    s=str{k};
    u=ustr{i};
    match(k)=strcmp(s,u);
end
end %return

%========================================

function A=predict_pta(ccms,ca,B,C)
[n1,n2,n3]=size(ccms);
for k=1:n1 % normalize to 100 trials
    ntr=sum(sum(ccms(k,:,:))); 
    ccms(k,:,:)=ccms(k,:,:)*100/ntr; 
end
X=reshape(ccms,n1,n2*n3);
A=mnr_val(B,X*C)*ca;
end %return

function phat=mnr_val(B,X)
n=size(B,2);
m=size(X,1);
o=ones(m,1);
z=[o X]*B;
p=1./(1+exp(-z));
phat=1;
for k=1:n
    pk=p(:,k);
    phat=[pk (1-pk).*phat]; % forward split
end
end %return
