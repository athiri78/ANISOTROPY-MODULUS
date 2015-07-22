function d = dot(m1,m2,varargin)
% inner product between two Miller indece
%
% Syntax
%   a = dot(m1,m2)
%   a = dot(m1,m2,'antipodal')
%
% Input
%  m1,m2 - @Miller
%
% Output
%  d - double [length(m1) length(cs)]
% 
% Options
%  antipodal - consider m1,m2 with antipodal symmetry
%  all       -

if ~isa(m1,'Miller') || ~isa(m2,'Miller') || m1.CS ~= m2.CS
  warning('Symmetry mismatch')
end


if length(m1) ~=1
  
  s = size(m1);
  
elseif length(m2) ~=1
  
  s = size(m2);

else
    
  d = dot_outer(m1,m2,varargin{:});
  
  if length(m1) == 1
    d = reshape(d,[size(m2),size(d,3)]);
  else
    d = reshape(d,[size(m1),size(d,3)]);
  end
  return
end

% symmetrize
m1 = vector3d(symmetrise(m1,varargin{:}));
m2 = vector3d(repmat(reshape(m2,1,[]),size(m1,1),1));


% normalize
m1 = m1 ./ norm(m1);
m2 = m2 ./ norm(m2);

% dotproduct
d = dot(m1,m2);

% find maximum
if ~check_option(varargin,'all')
  d = reshape(max(d,[],1),s);  
end
