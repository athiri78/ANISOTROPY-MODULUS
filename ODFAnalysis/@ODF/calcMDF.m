function mdf = calcMDF(odf1,varargin)
% calculate the uncorrelated misorientation distribution function (MDF) from one or two ODF
%
% Syntax
%   mdf = calcMDF(odf)
%   mdf = calcMDF(odf1,odf2,'bandwidth',32)
%
% Input
%  odf  - @ODF
%  odf1, odf2 - @ODF
%
% Options
% bandwidth - bandwidth for Fourier coefficients (default -- 32)
%
% Output
%  mdf - @ODF
%
% See also
% EBSD/calcODF

% Kernel method
if check_option(varargin,'kernelMethod') && isa(odf1,'unimodalODF') && ...
    (isa(varargin{1},'unimodalODF') || ~isa(varargin{1},'ODF'))

  % TODO
  mdf = calcMDF(odf1,varargin{:});
  
else % Fourier method
  
  % determine bandwidth
  L = get_option(varargin,'bandwidth',32);
  
  % convert to FourierODF
  odf1 = FourierODF(odf1,L);

  % extract Fourier coefficients
  L = min(odf1.components{1}.bandwidth,L);

  % is second argument also an ODF?
  if nargin > 1 && isa(varargin{1},'ODF')
    odf2 = FourierODF(varargin{1},L);
  else
    odf2 = odf1;
  end

  % compute MDF
  mdf = calcMDF(odf1.components{1},odf2.components{1});

end
