function odf = FourierODF(C,CS,SS,varargin)
% defines an ODF by its Fourier coefficients
%
%% Description
% *FourierODF* defines an  ODF by its Fourier coefficients
%
%% Syntax
%  odf = FourierODF(C,CS,SS)
%
%% Input
%  C      - Fourier coefficients / C -- coefficients
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/ODF uniformODF fibreODF unimodalODF

if isa(C,'ODF')
  
  odf = C(1);
  odf = set(odf,'center',[]);
  odf = set(odf,'c',1);
  odf = set(odf,'psi',[]);
  odf = set(odf,'options',{{'fourier'}});
  
  for i = 2:numel(C)
    odf = set(odf,'c_hat',get(odf,'c_hat') + get(C(i),'c_hat'));
  end
else
  error(nargchk(3,3,nargin));
  
  
  if isa(C,'cell')
    CC = [];
    for l = 0:length(C)-1
      CC = [CC;C{l+1}(:) * sqrt(2*l+1)]; %#ok<AGROW>
    end
    C = CC;
  end
  
  argin_check(C,'double');
  argin_check(CS,'symmetry');
  argin_check(SS,'symmetry');

  odf = ODF(C,[],[],CS,SS,'Fourier');
end
