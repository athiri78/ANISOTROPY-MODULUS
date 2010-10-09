%%

E = set(tensor,'name','elasticity')

%% Young's Modulus

x = xvector;
Y = YoungsModulus(E,x)

%%

plot(E,'PlotType','YoungsModulus')

%% Linear Compressibility

linearCompressibility(E,x)

%%

plot(E,'PlotType','linearCompressibility')

%% Cristoffel Tensor

C = CristoffelTensor(E,x)

%% Elastic Wave Velocity

[vp,vs1,vs2,pp,ps1,ps2] = velocity(E,x,1)

%%

plot(E,'PlotType','vp')
plot(E,'PlotType','vs1')
plot(E,'PlotType','vs2')

