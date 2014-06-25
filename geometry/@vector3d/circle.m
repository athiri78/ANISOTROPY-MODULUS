function h = circle(normals,varargin)
% annotated a circle
%
% Input
%  n     - a normal @vector3d
%  omega - an opening angle around n (default pi/2) (GreatCircle)
%         an @vector3d
%
% Options
%

% extract radius
if numel(varargin) >= 1 && isnumeric(varargin{1})
  omega = varargin{1};
  varargin(1) = [];
else
  omega  = 90*degree; 
end

h = [];

for i = 1:length(normals)

  n = normals.subSet(i);
  
  % generate circles
  c = axis2quat(n,(0:1:360)*degree) * axis2quat(orth(n),omega)*n;
  
  % plot circles
  h = [h,line(c,varargin{:},'hold')]; %#ok<AGROW>
  
end

if nargout == 0, clear h;end
