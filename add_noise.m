% Adds noise n to signal x. sn is signal-to-noise ratio
% There's no ramping for smooth onset & offset
% 
% Last modified: 12-10-2015
% Created by: Blinded Author Name
function [y,n]=add_noise(x,n,sn)
if isinf(sn)
    y=x;
    n=zeros(size(n));
    return
end
x=x(:);
n=n(:);
if length(n)>length(x)
    n=n(1:length(x));
else
    warning('length(n)<length(x)! Replicating n.')
    p=round(length(x)/length(n));
    for k=1:p
        n=[n;n];
    end
    n=n(1:length(x));    
end
level=get_spl(x);
x=set_spl(x,level);
n=set_spl(n,(level-sn));
y=n+x;
return
