% Residual_Loss - predict PTA & compute residual loss

function Residual_Loss
fn_mat='QVC_Combined.mat';
load(fn_mat,'T_Combined','ID','Np','Ns','Nt')
%
pta=fetch_pta(ID);
load('regress_xrl','B','C');
Bx=B;Cx=C;cax=[0;1];
load('regress_pta','B','C','ca');
%
score=zeros(Np,Ns);
ppta=zeros(Np,Ns);
ids=cell(Np*Nt,1);
vwl=cell(Np*Nt,1);
cns=cell(Np*Nt,1);
rsp=cell(Np*Nt,1);
for sk=1:Ns
    for pk=1:Np
        n=sk+(pk-1)*Ns;
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
    [uids,uvwl,ucns,ursp,nids]=unique_tbt(ids,vwl,cns,rsp);
    ilst=1:nids;
    ccms=compute_ccms(ilst,ids,vwl,cns,rsp,uids,uvwl,ucns,ursp);
    ppta(:,sk)=predict_pta(ccms,ca,B,C);
end
ID=uids(ilst);
id=char(ID);
pta=round(pta(:),1); % round decibels to 1 decimal place
ppta=round(ppta,1);  % round decibels to 1 decimal place
%write_data('ppta.txt',[pta(ii) ppta(ii)]);
% select unaided participants
kn=(id(:,1)=='N')&(~isnan(pta)); % normal-hearing participants (with PTA)
ku=(id(:,3)=='0')&(~isnan(pta)); % unaided participants (with PTA)
nnh=sum(kn);
nup=sum(ku);
nhp=mean(mean(score(kn,:)));
fprintf('participants: %d normal-hearing, %d unaided\n',nnh, nup);
fprintf('normal-hearing score: %.0f%%\n',nhp)
% plot percent correct
figure(1);clf
score=mean(score,2); % average across sessions
x0=[-10 60];
y0=[90 90];
plot(pta(ku),score(ku),'bo',x0,y0,'k:')
xlabel('PTA (dB)')
ylabel('percent correct')
axis([-10 60 5 105])
% plot predicted PTA
figure(2);clf
ppta=mean(ppta,2);
pa=[13.7 16.1];
x0=[-10 pa(2) 60];
y0=[pa(1) pa(1) 60+pa(1)-pa(2)];
plot(pta(ku),ppta(ku),'bo',x0,y0,'k:')
xlabel('PTA (dB)')
ylabel('predicted PTA (dB)')
axis([-10 60 -10 60])
% plot residual loss
figure(3);clf
rhl=ppta(ku)-max(pa(1),pta(ku)+pa(1)-pa(2));
rl1=4; % excess residual loss threshold 1
rl2=9;   % excess residual loss threshold 2
xx=[-10 60];
y1=[1 1]*rl1;
y2=[1 1]*rl2;
plot(pta(ku),rhl,'bo',xx,y1,'k:',xx,y2,'k:')
xlabel('PTA (dB)')
ylabel('residual loss (dB)')
axis([-10 60 -15 15])
% find excess residual loss
ke1=rhl>rl1;
ke2=rhl>rl2;
npe1=sum(ke1);
npe2=sum(ke2);
fprintf(' %2d with excess residual loss (>%.1f dB)\n',npe1,rl1)
fprintf(' %2d with excess residual loss (>%.1f dB)\n',npe2,rl2)
idu=id(ku,:);
for k=1:nup
    if (ke2(k))
        fprintf(' %s\n',idu(k,:))
    end
end
return

%========================================

function pta=fetch_pta(ID)
%fn_xls='../Data/QuickVCReliability_DATA.xlsx';
fn_xls = ['..' filesep 'Data' filesep 'VCVtest_DATA.xlsx'];
T=readtable(fn_xls,'Sheet','Audio and Tymps');
ids=char(T.SubjectID);
[ni,nc]=size(ids);
PTA=round(T.TestEarPTA_1_2_4KHz_,2)';
idc=char(ID);
nid=length(ID);
pta=zeros(1,nid);
for k=1:nid
    idk=idc(k,:);
    idk(3)='0'; % remove code for aided
    for j=1:ni
        if (strncmp(idk,ids(j,:),nc))
            pta(k)=PTA(j);
        end
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

%========================================

function write_data(fn,data)
[nr,nc] = size(data);
fp=fopen(fn,'wt');
fprintf(fp,'; %s\n', fn);
for i=1:nr
    for j=1:nc
        fprintf(fp,' %14.5g',data(i,j));
    end
    fprintf(fp,'\n');
end
fclose(fp);
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
            if (cnt) fprintf(fp,'%5d',cnt); end
        end
        fprintf(fp,'\n');
    end
    fprintf(fp,'\n\n');
end
fclose(fp);
return

%========================================

function A=predict_pta(ccms,ca,B,C)
[n1,n2,n3]=size(ccms);
for k=1:n1 % normalize to 100 trials
    ntr=sum(sum(ccms(k,:,:))); 
    ccms(k,:,:)=ccms(k,:,:)*100/ntr; 
end
X=reshape(ccms,n1,n2*n3);
A=mnr_val(B,X*C)*ca;
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
