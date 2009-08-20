function t = textureindex(odf,varargin)
% caclulate texture index of ODF
%
% The tetxure index of an ODF f is defined as:
%
% $$ t = -\int f(g)^2 dg$$
%
%% Input
%  odf - @ODF 
%
%% Output
%  texture index - double
%
%% Options
%  resolution - resolution of the discretization
%  fourier    - use Fourier coefficients 
%  bandwidth  - bandwidth used for Fourier calculation
%
%% See also
% ODF/entropy ODF/volume ODF_index ODF/calcFourier

if check_option(varargin,'fourier')
  
  L = get_option(varargin,'bandwidth',bandwidth(odf));
  t = norm(Fourier(odf,'bandwidth',L,'l2-normalization')).^2;
  
else
  % discretisation
  S3G = extract_SO3grid(odf,varargin{:});

  % eval odf
  t = eval(odf,S3G,varargin{:});
  t = t / sum(t) * length(t);
  t = sum(t.^2)/GridLength(S3G);
end
