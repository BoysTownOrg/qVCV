% get SPL of signal x
function L=get_spl(x,splref)
if nargin<2,splref=1.1219e-6;end
L=20.*log10(rms(x)/splref);
return
%