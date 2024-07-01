% score_par - Compute SCORE & PPTA for one participant session

%DataDir='..\Data\Quick-VC';
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
