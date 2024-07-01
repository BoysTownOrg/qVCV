function vcv2xls(xlsfn,Sheet,VCVdata)
warning('off','MATLAB:xlswrite:AddSheet')

Nvcv=size(VCVdata,2);

for vcvk=1:Nvcv
    trial(vcvk,1)=vcvk;
    token{vcvk,1}=VCVdata(vcvk).token;
    token_number(vcvk,1)=VCVdata.token_number;
    snr(vcvk,1)=VCVdata(vcvk).snr;
    vowel(vcvk,1)=VCVdata(vcvk).vowel;
    consonant{vcvk,1}=VCVdata(vcvk).consonant;
    response{vcvk,1}=VCVdata(vcvk).response;
    score(vcvk,1)=VCVdata(vcvk).score;
end

% VCVdataset=dataset;
% VCVdataset.trial=trial(:);
% VCVdataset.token=token(:);
% VCVdataset.token_number=token_number(:);
% VCVdataset.snr=snr(:);
% VCVdataset.vowel=vowel(:);
% VCVdataset.consonant=consonant(:);
% VCVdataset.response=response(:);
% VCVdataset.score=score(:);

VCVdataset = table(trial, token, token_number, snr, vowel, consonant, response, score);
writetable(VCVdataset, xlsfn, 'Sheet',Sheet);
% export(VCVdataset,'XLSfile',xlsfn,'Sheet',Sheet)


fprintf('\nData saved\n\tFilename: %s\n\tTab name: %s \n',xlsfn,Sheet)


return