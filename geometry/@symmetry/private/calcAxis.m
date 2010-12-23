function abc  = calcAxis(axisLength,angle,varargin)
% calculate the axis a, b, c of the crystal coordinate system with respect
% to the euclidean reference frame
%
%% Input
%
%
%% Output
%

%% get axis length
if axisLength(3) == 0, axisLength(3) = max(axisLength);end
if axisLength(3) == 0, axisLength(3) = 1;end

if axisLength(1) == 0, axisLength(1) = axisLength(2);end
if axisLength(2) == 0, axisLength(2) = axisLength(1);end
if axisLength(2) == 0, 
  axisLength(2) = axisLength(3);
  axisLength(1) = axisLength(3);
end

%% get angles
if angle(1) == 0
  if angle(2) == 0, angle(2) = pi/2;end
  angle(1) = pi - angle(2);
end
if angle(2) == 0,  angle(2) = pi - angle(1);end
if angle(3) == 0, angle(3) = pi/2;end

%% start be defining a reference coordinate system
% which uses the convention
% * X || a
% * Z || c*
a = xvector;
b = cos(angle(3)) * xvector + sin(angle(3)) * yvector;
c = cos(angle(2)) * xvector + ...
  (cos(angle(1)) - cos(angle(2)) * cos(angle(3)))/sin(angle(3)) * yvector +...
  sqrt(1+2*prod(cos(angle)) - sum(cos(angle).^2))/sin(angle(3)) * zvector;

%% compute a* b* c*

astar = normalize(cross(b,c));
bstar = normalize(cross(c,a));
cstar = normalize(cross(a,b));


%% extract alignment options
% restrict to strings
varargin = varargin(cellfun(@(s) ischar(s),varargin));

% if nothing or only Y is specified set Z||c
if ~any(cell2mat(regexpi(varargin,'[xz]\|\|')))
  varargin = [varargin,{'Z||c'}];
end

% setup new x, y, z directions
xyzNew = vector3d(zeros(3));
axes = ['X','Y','Z'];
for ia = 1:3

  % extract alignment for this specific axis
  alignment = regexpi(varargin,[axes(ia) '\|\|(\w\*?)'],'tokens');
  alignment = [alignment{:}];
  alignment = char(alignment{:});
  
  
  switch lower(alignment)
 
    case 'a'
      xyzNew(ia) = a;
      if rem(ia,2) && norm(xyzNew(4-ia))<1e-6 && norm(xyzNew(2))<1e-6
        xyzNew(4-ia) = cstar;
      end
    case 'b'
      xyzNew(ia) = b;
    case 'c'
      xyzNew(ia) = c;
      if rem(ia,2) && norm(xyzNew(4-ia))<1e-6 && norm(xyzNew(2))<1e-6
        xyzNew(4-ia) = astar;
      end
    case 'a*'
      xyzNew(ia) = astar;
      if rem(ia,2) && norm(xyzNew(4-ia))<1e-6 && norm(xyzNew(2))<1e-6
        xyzNew(4-ia) = c;
      end
    case 'b*'
      xyzNew(ia) = bstar;
    case 'c*'
      xyzNew(ia) = cstar;
      if rem(ia,2) && norm(xyzNew(4-ia))<1e-6 && norm(xyzNew(2))<1e-6
        xyzNew(4-ia) = a;
      end
    case 'm'
      xyzNew(ia) = m;
  end
end
  
% set any missing axis as the cross product of the two others
for ia = 1:3
  if norm(xyzNew(ia)) < 1e-6
    xyzNew(ia) = cross(xyzNew(mod(ia,3)+1),xyzNew(mod(ia+1,3)+1));
  end
end

% set up the transformation matrix
M = reshape(double(normalize(xyzNew)),3,3);

% check for orthogonality
if norm(M^(-1) - M') > 1e-6
  error('Bad alignment options! Non Euclidean reference frame!')
end

% now compute the new a, b, c axes
abc = vector3d((M * reshape(double(normalize([a,b,c])),3,3).')) .* axisLength(:).';
