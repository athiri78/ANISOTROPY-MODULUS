function ori = discreteSample(odf,npoints,varargin)
% evaluate an odf at orientation g
%

theta = randomSample(odf.psi,npoints,'fibre');
rho   = 2*pi*rand(points,1);
angle = 2*pi*rand(points,1);

q0 = hr2quat(odf.h,odf.r);

ori =  orientation(axis2quat(r,rho) .* axis2quat(orth(r),theta) ...
  .* axis2quat(r,angle) .* q0, odf.CS, odf.SS);
