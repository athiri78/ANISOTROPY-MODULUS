function f = eval_fourier(odf,g,varargin)
% evaluate odf using NSOFT
%
%% Input
%  odf - @ODF
%  g   - @quaternion
% 
%% Output
%  f - double
%

global mtex_path;

% set parameter
L = dim2deg(length(odf.c_hat));
L = int32(min(L,get_option(varargin,'bandwidth',L)));

s = size(g);
[alpha,beta,gamma] = quat2euler(g);
alpha = fft_rho(alpha);
beta  = fft_theta(beta);
gamma = fft_rho(gamma);
g = 2*pi*[alpha(:),beta(:),gamma(:)].';
	
f_hat = [real(odf.c_hat(:)),imag(odf.c_hat(:))].';

% run NFSOFT
f = reshape(run_linux([mtex_path,'/c/bin/fc2odf'],'intern',L,'EXTERN',g,f_hat),...
  s);
    
