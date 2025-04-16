function qvcv_ccm
load('QVC_Combined')
[ccmss,ucns,ursp,uids]=make_ccms(ID,T_Combined);
ccms=squeeze(sum(ccmss,2)); % sum across repeated measures
save('qvcv_ccm.mat','ccms','ucns','ursp','uids');
return

%====================================================

function [ccmss,ucns,ursp,uids]=make_ccms(ID,T_Combined)
Np=length(ID);
[ts,Nt]=size(T_Combined);
Ns=ts/Np;
ccmss=zeros(Np,Ns,10,11);
ids=cell(Np*Nt,1);
vwl=cell(Np*Nt,1);
cns=cell(Np*Nt,1);
rsp=cell(Np*Nt,1);
for sk=1:Ns
    for pk=1:Np
        n=sk+(pk-1)*Ns;
        tbt=transpose(T_Combined(n,:));
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
    ccmss(:,sk,:,:)=ccms;
end
return

%----------------------------------------------------

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

%----------------------------------------------------

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
