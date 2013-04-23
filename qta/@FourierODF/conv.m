function odf = conv(odf,psi,varargin)
% convolute ODF with kernel psi
%
%% Input
%  odf - @ODF
%  psi - convolution @kernel
%
%% See also
% ODF_calcFourier ODF_Fourier

L = bandwidth(odf);
A = getA(psi);
A(end+1:L+1) = 0;

% multiply Fourier coefficients of odf with Chebyshev coefficients of psi
for l = 0:L
  odf.c_hat(deg2dim(l)+1:deg2dim(l+1)) = A(l+1) / (2*l+1) * odf.c_hat(deg2dim(l)+1:deg2dim(l+1));
end
