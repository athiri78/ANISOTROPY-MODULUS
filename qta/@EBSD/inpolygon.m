function ind = inpolygon(ebsd,xy)
% checks which ebsd data are within given polygon
%
%% Syntax
% ind = inpolygon(ebsd,[x1 y1; x2 y2; x3 y3; x4 y4]) -
% ebsd_sub = ebsd( inpolygon(ebsd,[x1 y1; x2 y2; x3 y3; x4 y4]) ) -
%
%% Input
%  ebsd    - @EBSD
%  [x, y]  - vertices of a polygon
%
%% Ouput
%  ind - logical
%
%% See also
% inpolygon

% get xy coordinates
XY = get(ebsd,'xy');

% shortcut for simple rectangles
if numel(xy)==4
  
  corners = [1 2; 3 2; 3 4; 1 4; 1 2];
  xy = xy(corners);
  
end

if ~isempty(XY)
  %  check for inside
  ind = inpolygon(XY(:,1),XY(:,2),xy(:,1),xy(:,2));
  
end
