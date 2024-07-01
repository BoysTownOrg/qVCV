% set signal x to desired dB SPL L1
function [x,L2]=set_spl(x,L1,splref)
if nargin<3,splref=1.1219e-6;end
Lcs=20.*log10(rms(x)/splref);
dL=L1-Lcs;
x=x.*10.^(dL/20);
L2=20.*log10(rms(x)/splref);
return
%