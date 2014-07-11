function  sR = fundamentalSector(cs,varargin)
% get the fundamental sector for a symmetry in the inverse pole figure
%
% Input
%  cs - symmetry
%
% Ouput
%  sR - spherical Region
%
% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%

% antipodal symmetry is nothing else then adding inversion to the symmetry
% group
if check_option(varargin,'antipodal'), cs = cs.Laue; end

% a first very simple rule for the fundamental region

% if we have an inversion or some symmetry operation no parallel to z
if any(angle(zvector,symmetrise(zvector,cs))>pi/2+1e-4)  
  N = zvector; % then we can map everything on the norther hemisphere
else
  N = vector3d;
end

% the region on the northern hemisphere now depends just on the
% number of symmetry operations
if length(cs) > 1+length(N)
  drho = 2*pi * (1+length(N)) / length(cs);
  N = [N,vector3d('theta',90*degree,'rho',[90*degree,drho-90*degree])];
end

aAxis = cs.axes(1);

% some special cases
switch cs.id
  
  case 1 % 1       
  case 2 % -1    
    N = zvector;    
  case {3,6,9} % 2    
    if isnull(dot(getMinAxes(cs),zvector))
      N = zvector;
    else
      ind = find(isnull(dot(getMinAxes(cs),cs.axes)),1);
      N = cs.axes(ind);
    end
  case {4,7,10} % m
    N = getMinAxes(cs);
  case 5 % 2/m11
    N = rotate(N,-90*degree);
  case {8,11} % 12/m1 112/m  
  case 12 % 222    
  case {13,14,15} % 2mm, m2m, mm2
    N = cs.subSet(cs.isImproper).axis; % take mirror planes
  case 16 % mmm
  case 17 % 3
  case 18 % 3, -3
    N = rotate(N,-mod(round(aAxis.rho./degree)+30,120)*degree);   
  case {19,20,21} % 32, 3m, -3m
    N = rotate(N,-mod(round(aAxis.rho./degree)+30,120)*degree);   
  case {22,23,24}
    N = rotate(N,-mod(round(aAxis.rho./degree),60)*degree);   
  case 30 %-42m
    N = rotate(N,-45*degree);
  case {33,34,35,36} % 6, 622    
    N = rotate(N,-mod(round(aAxis.rho./degree+30),60)*degree);  
  case 38 % 62m
    N = rotate(N,-mod(round(aAxis.rho./degree),60)*degree);
  case 39 % 6m2
    N = rotate(N,-mod(round(aAxis.rho./degree+30),60)*degree);
  case 41 % 23
    %N = [vector3d(0,-1,1),vector3d(-1,0,1),vector3d(1,0,1),yvector,zvector];
    N = vector3d([1 1 0 0],[1 -1 1 -1],[0 0 1 1]);
  case 42 % m-3
    N = [vector3d(0,-1,1),vector3d(-1,0,1),xvector,yvector,zvector];
  case 43 % 432
    N = [vector3d(1,-1,0),vector3d(0,-1,1),yvector];
  case 44 % -43m
    N = [vector3d(1,-1,0),vector3d(1,1,0),vector3d(-1,0,1)];
  case 45 % m-3m    
    N = [vector3d(1,-1,0),vector3d(-1,0,1),yvector];
end

if check_option(varargin,{'complete','3d'})
  sR = sphericalRegion;
else
  sR = sphericalRegion(N);
end

