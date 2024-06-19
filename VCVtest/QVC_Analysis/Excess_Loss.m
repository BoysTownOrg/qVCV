% Excess_Loss - predict excessive residual loss

function Excess_Loss
fn_mat='QVC_Combined.mat';
load(fn_mat,'T_Combined','ID','Np','Ns','Nt')
%
load('regress_xrl','B','C') % excessive-residual-loss regression 
%
score=zeros(Np,Ns);
pxl=zeros(Np,Ns);
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
    pxl(:,sk)=predict_pta(ccms,[0;1],B,C);
end
ID=uids(ilst);
id=char(ID);
rlth=5; % excess residual loss threshold
% predict excess residual loss
ku=(id(:,3)=='0'); % unaided participants with PTA
nup=sum(ku);
fprintf('%d unaided participants\n',nup);
pxl=mean(pxl(ku),2);
ke=pxl>prctile(sort(pxl),90);
npel=sum(ke);
fprintf('%d participants most likely to have residual loss >%d dB:\n',npel,rlth)
idu=id(ku,:);
for k=1:nup
    if (ke(k))
        fprintf(' %s  %2d%%\n',idu(k,:),round(100*pxl(k)))
    end
end
return

%========================================

function pta=fetch_pta(ID)
fn_xls='../Data/QuickVCReliability_DATA.xlsx';
T=readtable(fn_xls,'Sheet','Audio and Tymps');
ids=char(T.SubjectID);
[ni,nc]=size(ids);
PTA=round(T.TestEarPTA_1_2_4KHz_,2)';
idc=char(ID);
nid=length(ID);
pta=zeros(1,nid);
for k=1:nid
    idk=idc(k,:);
    idk(3)='0'; % remove cide for aided
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
