% Residual_Loss - predict PTA & compute residual loss

function Residual_Loss
fn_mat='QVC_Combined.mat';
load(fn_mat,'T_Combined','ID','cat','ses','idx')
Np=size(ID,1);
pta=fetch_pta(ID);
nmt=sum(isnan(pta)); % number of missing thresholds
fprintf('participants=%d; missing_thresholds=%d\n',Np,nmt);
%
[score,ppta]=score_ppta(ID,T_Combined,ses,idx);
[ppta,pa]=audibility_adjustment(pta,ppta);
% select unaided participants
id=ID;
kn=(cat==1); % normal-hearing participants (with PTA)
ki=(cat~=1);
nnh=sum(kn);
nup=sum(ki);
nhp=mean(mean(score(kn,:)));
fprintf('participants: %d normal-hearing, %d hearing-impared\n',nnh, nup);
fprintf('average normal-hearing score: %.0f%%\n',nhp)
% plot percent correct
figure(1);clf
ii=(ses<2);
score(ii,2)=score(ii,1);
score=mean(score,2); % average across sessions
x0=[-10 70];
y0=[90 90];
plot(pta(kn),score(kn),'bo',pta(ki),score(ki),'ro',x0,y0,'k:')
xlabel('PTA (dB)')
ylabel('percent correct')
axis([-10 70 5 105])
% plot predicted PTA
figure(2);clf
ppta=mean(ppta,2);
x0=[-10 pa(2) 60];
y0=[pa(2) pa(2) 60];
plot(pta(kn),ppta(kn),'bo',pta(ki),ppta(ki),'ro',x0,y0,'k:')
xlabel('PTA (dB)')
ylabel('predicted PTA (dB)')
axis([-10 70 -10 60])
% plot residual loss
rlx=5; % excess residual loss threshold
figure(3);clf
aud=max(pa(2),pta);
rhl=ppta(ki)-aud(ki);
xx=[-10 70];
y1=[1 1]*rlx;
plot(pta(ki),rhl,'bo',xx,y1,'k:')
xlabel('PTA (dB)')
ylabel('residual loss (dB)')
axis([-10 70 -20 30])
% find excess residual loss
kx=(rhl>rlx);
npx=sum(kx);
fprintf('%2d with residual loss (>%.1f dB)\n',npx,rlx)
idu=id(ki,:);
ptau=pta(ki,:);
for k=1:nup
    if (kx(k))
        fprintf(' %s: pta=%4.1f rhl=%4.1f\n',idu(k,:),ptau(k),rhl(k))
    end
end
return

%========================================

function pta=fetch_pta(ID)
%fn_xls = ['..' filesep 'Data' filesep 'QuickTests_DATA.xlsx'];
%T=readtable(fn_xls,'Sheet','Audio and Tymps');
fn_xls = fullfile('..','Data','VCVtest_DATA.xlsx');
T=readtable(fn_xls);
ids=char(T.SubjectID);
[ni,nc]=size(ids);
PTA=round(T.TestEarPTA_1_2_4KHz_,2)';
idc=char(ID);
nid=size(ID,1);
pta=nan(nid,1);
for k=1:nid
    idk=idc(k,:);
    for j=1:ni
        if (strncmp(idk,ids(j,:),nc))
            pta(k)=PTA(j);
        end
    end
end
return

%========================================

function [score,ppta]=score_ppta(ID,T_Combined,ses,idx)
load('mnr_vcv_pta','B','C','ca');
Np=size(ID,1);
Nt=size(T_Combined,2);
Ns=max(ses);
score=zeros(Np,Ns);
ppta=zeros(Np,Ns);
ccmss=zeros(Np,Ns,10,11);
ids=cell(Np*Nt,1);
vwl=cell(Np*Nt,1);
cns=cell(Np*Nt,1);
rsp=cell(Np*Nt,1);
for sk=1:Ns
    for pk=1:Np
        if (sk>ses(pk)), continue; end
        n=idx(pk)+sk-1;
        tbt=transpose(T_Combined(n,:));
        S=floor(char(tbt.score));
        score(pk,sk)=sum(S);
        for tk=1:Nt
            kk=tk+(pk-1)*Nt;
            ids{kk}=ID(pk,:);
            vwl{kk}=tbt(tk).vowel;
            cns{kk}=tbt(tk).consonant;
            rsp{kk}=tbt(tk).response;
        end
    end
    %-------------------------------------------------------------------
    if (sk==1)
        [uids,uvwl,ucns,~,nids]=unique_tbt(ids,vwl,cns,rsp);
        ursp=[ucns;'other'];
    end
    ilst=1:nids;
    ccms=compute_ccms(ilst,ids,vwl,cns,rsp,uids,uvwl,ucns,ursp);
    ppta(:,sk)=regress_ccms(ccms,ca,B,C);
    ccmss(:,sk,:,:)=ccms;
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
ccms=squeeze(ccms);
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

function match=ncmp(str,ustr,i)
n=length(str);
m=length(ustr{1});
match=ones(n,1);
for k=1:n
    s=str{k};
    u=ustr{i};
    match(k)=strncmp(s,u,m);
end
return

function write_csv(fn,ccms,ilst,uids,ucns,ursp)
[ni,nc,nr] = size(ccms);
fp=fopen(fn,'wt');
for i=1:ni
    fprintf(fp,'%s',char(uids(ilst(i))));
    for j=1:nr
        fprintf(fp,',%s',char(ursp(j)));
    end
    fprintf(fp,'\n');
    for k=1:nc
        fprintf(fp,'%s',char(ucns(k)));
        for j=1:nr
            cnt=ccms(i,k,j);
            fprintf(fp,',');
            if (cnt) fprintf(fp,'%5.0f',cnt); end
        end
        fprintf(fp,'\n');
    end
    fprintf(fp,'\n\n');
end
fclose(fp);
return

%-------------------------------------------------------------------

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

function [ppta,pa]=audibility_adjustment(pta,ppta)
pa=[16 18];
op=[];
pa=fminsearch(@(pa) aud_err(pa,pta,ppta),pa,op);
ppta=ppta+pa(2)-pa(1);
return

function err=aud_err(pa,pta,ppta)
i1=pta<=10;
i2=pta>=20;
err1=mean((ppta(i1)-pa(1)).^2);
err2=mean((ppta(i2)-pa(1)-pta(i2)+pa(2)).^2);
err=err1+err2;
return

%-------------------------------------------------------------------

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
