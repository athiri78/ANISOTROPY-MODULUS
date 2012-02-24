function [h,r,v] = guessfibre(g1,g2,varargin)
% try to find the fibre of to given rotations by finding the eigenvector
% of g_1*h = g_2*h -> (g_2^-1)*g_1* h = h -> R*h = (lambda)*h
%
%% Input
%  g1 - @rotation, @odf
%  g2 - @rotation
%
%% Output
%  h - 
%  r - 
%  v - (in case of odf) fibre volumn
%
%% Options
%  resolution - discretisation parameter
%
%% See also
% fibreODF rotation

if isa(g1,'ODF')
  CS = get(g1,'CS');
  
  qmax = rotation(max(g1,2,varargin{:})); %get to maximum rotations
   
  if numel(qmax) <2,
    error('to less maxima in the odf, probably no fibre...')
  end
  
  v = zeros(size(CS));
  for k=1:numel(CS)  % check every symmetry element  since ambiguity
    [h,r] = guessfibre(qmax(1),qmax(2)*CS(k),varargin{:});
    v(k) = fibreVolume(g1,Miller(h,CS),r,10*degree,'resolution',5*degree,varargin{:});
  end
  % and take the one with maximum volumn
  [v l] = max(v);
  
  [h,r] = guessfibre(qmax(1),qmax(2)*CS(l));
  h = Miller(h,CS);
  return
end


g = [g1 g2];
if isa(g1,'orientation')
  g = project2FundamentalRegion(g,g2); 
end

[ev ew] = eig(matrix(inverse(g(1))*g(2)));

b = ~any(imag(ev),1); % take the real valued
    % ~imag(diag(ew))
if any(b)
  h = vector3d( ev(:,b));
  r = g1*h;
else
  error('no realvalued eigenvector');
end

