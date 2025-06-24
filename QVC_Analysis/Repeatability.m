% Repeatability - analyze repeatability between two sessions

function Repeatability
fn_mat='QVC_Combined.mat';
load(fn_mat,'T_Combined','ID','cat','ses')
NH=(cat==1);
HI=(cat~=1);
Nn=sum(NH);Ni=sum(HI);
%
[score,ppta]=score_all(T_Combined,ID,ses);
scatter_plot('score',score,NH,HI,1);
scatter_plot('ppta',ppta,NH,HI,2);
%
if (size(score,1)>1)
    fn_xls=sprintf('%s_Summary.xlsx','QVC');
    score1=score(:,1);
    score2=score(:,2);
    ppta1=ppta(:,1);
    ppta2=ppta(:,2);
    T=table(ID,score1,score2,ppta1,ppta2);
    writetable(T,fn_xls)
end
kn=Ni+(1:Nn);
nhs=mean(mean(score(kn,:)));
mad=mean(abs(ppta(:,1)-ppta(:,2)));
fprintf('NH%%=%.0f  PPTA_MAD=%.1f dB\n',nhs,mad);
if (size(score,1)>1)
    R=[corr(score(:,1),score(:,2)) corr(ppta(:,1),ppta(:,2))];
    fprintf('R(score,PPTA)=%.2f %.2f\n',R);
end
return

function [score,ppta]=score_all(T_Combined,ID,ses)
idx=[1;1+cumsum(ses(1:(end-1)))];
Nt=size(T_Combined,2);
Np=size(ID,1);
Ni=2;
fprintf('%d participants, %d instances, %d trials\n',Np,Ni,Nt);
%
score=zeros(Np,Ni);
ppta=zeros(Np,Ni);
for pk=1:Np
    id=ID(pk,:);
    ii=(idx(pk)-1)+(1:ses(pk));
    [s,p]=score_par(T_Combined(ii,:),id,ses);
    score(pk,:)=s;
    ppta(pk,:)=p;
end
return

%========================================

function [score,ppta]=score_par(T_Participant,ID,ses)
Nt=size(T_Participant,2);
Np=size(ID,1);
Ni=2;
load('mnr_vcv_pta','B','C','ca')
uvwl={'a'};
ucns={'b','d','g','k','n','s','sh','t','v','z'};
ursp={'b','d','g','k','n','s','sh','t','v','z','other'};
ilst=1;
%
score=zeros(Np,Ni);
ppta=zeros(Np,Ni);
for pk=1:Np
    uids={ID(pk,:)};
    Ns=ses(pk);
    for ik=1:Ni
        nn=Nt*Ns/Ni;
        ids=cell(nn,1);
        vwl=cell(nn,1);
        cns=cell(nn,1);
        rsp=cell(nn,1);
        tbt=[];
        for sk=1:Ns
            for tk=1:Nt
                T=T_Participant(sk,tk);
                if (T.token_number==ik)
                    tbt=[tbt;T];
                end
            end
        end
        for tk=1:nn
            ids{tk}=ID(pk,:);
            vwl{tk}=tbt(tk).vowel;
            cns{tk}=tbt(tk).consonant;
            rsp{tk}=tbt(tk).response;
        end
        ccms=compute_ccms(ilst,ids,vwl,cns,rsp,uids,uvwl,ucns,ursp);
        ccm=squeeze(ccms);
        ppta(pk,ik)=regress_ccms(ccms,ca,B,C);
        score(pk,ik)=100*sum(diag(ccm))/sum(sum(ccm));
    end
end
return

%========================================

function scatter_plot(var,v,i1,i2,fig)
figure(fig);clf;
x1=v(i1,1);
y1=v(i1,2);
x2=v(i2,1);
y2=v(i2,2);
plot(x1,y1,'bo',x2,y2,'ro')
xlabel([var ' 1']);
ylabel([var ' 2']);
rho=corr(v(:,1),v(:,2));
vmn=min(min(v))-3;
vmx=max(max(v))+3;
axis([vmn vmx vmn vmx])
x=(vmn+0.7*(vmx-vmn));
y=(vmn+0.1*(vmx-vmn));
text(x,y,sprintf('R=%.2f',rho));
legend('NH','HI','Location','northwest')
return

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
return

function match=cmp(str,ustr,i)
n=length(str);
match=ones(n,1);
for k=1:n
    s=str{k};
    u=ustr{i};
    match(k)=strcmp(s,u);
end
return

%========================================

function A=regress_ccms(ccms,ca,B,C)
[n1,n2,n3]=size(ccms);
X=reshape(norm_ccm(ccms),n1,n2*n3);
A=mnr_val(B,X*C)*ca;
return

function ccms=norm_ccm(ccms)
n1=size(ccms,1);
for k=1:n1 % normalize to 100 trials
    ntr=sum(sum(ccms(k,:,:))); 
    ccms(k,:,:)=ccms(k,:,:)*100/ntr; 
end
return

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
return
