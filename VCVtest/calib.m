clear all
[s,fs]=audioread('noise_0dB.wav');

z=zeros(size(s));

y1=[s,z];
y2=[z,s];

nt=length(s);
t=(0:nt-1)./fs;
x=cos(2*pi*2000.*t');
x=x.*(rms(s)./rms(x));

yy1=[x,z];
yy2=[z,x];

yn=add_noise(x,s,12);
yn1=[yn,z];
yn2=[z,yn];

fprintf('\nPLAYING TONE\n')
p=audioplayer(yn2,fs);play(p);playblocking(p);

return
fprintf('\nPLAYING NOISE\n')
p=audioplayer(y2,fs);play(p);playblocking(p);

figure(1); clf
plot(s,'b'); hold on
plot(x,'r')
