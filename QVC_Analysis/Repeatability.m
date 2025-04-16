% Repeatability - analyze repeatability between two sessions

function Repeatability
fn_mat='QVC_Combined.mat';
load(fn_mat,'T_Combined','ID','Nu')
Ni=Nu(1);Nn=Nu(2);
%
[score,ppta]=score_all(T_Combined,ID);
scatter_plot('score',score,Nu,1);
scatter_plot('ppta',ppta,Nu,2);
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

function [score,ppta]=score_all(T_Combined,ID)
[ts,Nt]=size(T_Combined);
Np=size(ID,1);
Ns=ts/Np;
fprintf('%d participants, %d sessions, %d trials\n',Np,Ns,Nt);
%
score=zeros(Np,Ns);
ppta=zeros(Np,Ns);
for pk=1:Np
    T_participant=T_Combined((1:Ns)+(pk-1)*Ns,:);
    id=ID(pk,:);
    [s,p]=score_par(T_participant,id);
    score(pk,:)=s;
    ppta(pk,:)=p;
end
return

%========================================

function [score,ppta]=score_par(T_Combined,ID)
[ts,Nt]=size(T_Combined);
Np=size(ID,1);
Ns=ts/Np;
%fprintf('%d participants, %d sessions, %d trials\n',Np,Ns,Nt);
load('mnr_vcv_pta','B','C','ca')
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
        score(pk,sk)=sum(S)*(100/length(S));
        for tk=1:Nt
            ids{tk}=ID(pk,:);
            vwl{tk}=tbt(tk).vowel;
            cns{tk}=tbt(tk).consonant;
            rsp{tk}=tbt(tk).response;
        end
        ccms=compute_ccms(ilst,ids,vwl,cns,rsp,uids,uvwl,ucns,ursp);
        ppta(pk,sk)=regress_ccms(ccms,ca,B,C);
    end
end
return

%========================================

function [uids,uvwl,ucns,ursp,nids,nvwl,ncns,nrsp]=unique_tbt(ids,vwl,cns,rsp)
uids=sort(unique(ids));
uvwl=sort(unique(vwl));
ucns=sort(unique(cns));
ursp=sort(unique(rsp));
nids=length(uids);
nvwl=length(uvwl);
ncns=length(ucns);
nrsp=length(ursp);
% move 'other' response to end
for k=6:(nrsp-1)
    ursp{k}=ursp{k+1};
end
ursp{end}='other';
return

function scatter_plot(var,v,Nu,fig)
figure(fig);clf;
Np=sum(Nu);
i1=1:Nu(1);
i2=(Nu(1)+1):Np;
x1=v(i1,1);
y1=v(i1,2);
x2=v(i2,1);
y2=v(i2,2);
plot(x1,y1,'ro',x2,y2,'bo')
xlabel([var ' 1']);
ylabel([var ' 2']);
rho=corr(v(:,1),v(:,2));
vmn=min(min(v))-3;
vmx=max(max(v))+3;
axis([vmn vmx vmn vmx])
x=(vmn+0.7*(vmx-vmn));
y=(vmn+0.1*(vmx-vmn));
text(x,y,sprintf('R=%.2f',rho));
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
