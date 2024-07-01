function vcv2xls_multi(id)
warning('off','MATLAB:xlswrite:AddSheet')


fprintf('\nParticipant ID: %s\n',id)

dr='Results';
fol=[dr,filesep,id];

xlsfn=sprintf('%s_VCVdata.xls',id);
xlsfn=[dr,filesep,id,filesep,xlsfn];

fns=dir([fol,filesep,'*mat']);

if isempty(fns)
    fprintf('\nNo DATA! Could not find any data for participant %s\n',id)
    msgbox(sprintf('Could not find any data for participant %s',id),'No Data!','Warn','modal')
    return
end

Nfns=length(fns);
fprintf('\nFound data for %d sessions\n',Nfns)


for fk=1:Nfns
    fn=fns(fk).name;
    
    fn2=strrep(fn,'.mat','');
    I=strfind(fn2,'_');
    session=str2double(fn2(I(end)+1:end));
    Sheet=sprintf('Session %2d',session);

    load([fol,filesep,fn])
    vcv2xls(xlsfn,Sheet,VCVdata)    
end

fprintf('\nData saved as %s\n',xlsfn)


return
