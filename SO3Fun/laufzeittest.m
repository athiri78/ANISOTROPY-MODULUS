clear all

rot = orientation.rand(1000);
SO3F = calcDensity(rot,'harmonic','bandwidth',64,'halfwidth',2.5*degree);
SO3F = SO3FunHarmonic(SO3F.components{1}.f_hat)


ori=rotation.rand(1);


%%
tic
f0=eval(SO3F,ori);
toc

tic
f1 = SO3F.evalfft(ori,'nearest');
%f1=eval2(SO3F,ori);
toc

%tic
%    f2=eval2v3(SO3F,ori);
%toc

tic
f3=eval2v32(SO3F,ori);
toc

max(abs(f0-f1))
%max(abs(f0-f2))
max(abs(f0-f3))
