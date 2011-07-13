function q = vec42quat(u1,v1,u2,v2)
% returns a quaternion q with q u_1 = v1 and q u2 = v2
%
%% Description
% The method *vec42quat* defines a [[quaternion_index.html,quaternion]] |q|
% by 4 directions |u1|, |u2|, |v1| and |v2| such that |q * u1 = v1| and |q
% * u2 = v2| 
%
%% Input
%  u1, u2 - @vector3d
%  v1, v2 - @vector3d
%
%% Output
%  q - @quaternion
%
%% See also
% quaternion_index quaternion/quaternion axis2quat Miller2quat 
% euler2quat hr2quat idquaternion 

u1 = vector3d(u1);
u2 = vector3d(u2);

% ckeck whether points have the same angle relative to each other
if any(abs(dot(u1,u2)-dot(v1,v2))>1E-3)
  warning(['Inconsitent pairs of vectors encounterd!',...
    ' Maximum distorsion: ',...
    num2str(max(abs(acos(dot(u1,u2))-acos(dot(v1,v2))))/degree),mtexdegchar]) %#ok<WNTAG>
end

q = repmat(idquaternion,size(u1));

d1 = u1 - v1;
d2 = u2 - v2;


%% case 1: u1 = v1 & u2 = v2
% -> nothing has to be done, see initialisation
indLeft = ~(abs(d1)<1e-6 & abs(d2)<1e-6);


%% case 2: u1 == v1 -> rotation about u1
ind = indLeft & abs(d1)<1e-6;
indLeft = indLeft & ~ind;

% make orthogonal to u1
pu2 = u2(ind) - dot(u2(ind),u1(ind)).*u1(ind);
pv2 = v2(ind) - dot(v2(ind),v1(ind)).*v1(ind);
% compute angle
omega = acos(dot(pu2,pv2));

% compute axis
a = cross(pu2,pv2);
a = a ./ norm(a);

% the above axi can be zero for 180 degree rotations -> then u1 is ok
a = 2*a + u1;
a = a ./ norm(a);

% define rotation
q(ind) = axis2quat(a,omega);


%% case 3: u2 == v2 -> rotation about u2
ind = indLeft & abs(d2)<1e-6;
indLeft = indLeft & ~ind;

% make orthogonal to u2
pu1 = u1(ind) - dot(u1(ind),u2(ind)).*u2(ind);
pv1 = v1(ind) - dot(v1(ind),v2(ind)).*v2(ind);
% compute angle
omega = acos(dot(pu1,pv1));

% compute axis
a = cross(pu1,pv1);
a = a ./ norm(a);

% the above axi can be zero for 180 degree rotations -> then u2 is ok
a = 2*a + u2;
a = a ./ norm(a);

% define rotation
q(ind) = axis2quat(a,omega);


%% case 4: u1 = +- u2 -> rotation about u1 x v1

ind = indLeft & (abs(u1+u2)<1e-6 | abs(u1-u2)<1e-6);
indLeft = indLeft & ~ind;

% compute axis
ax = cross(u1(ind),v1(ind));
ax = ax./norm(ax);

% compute angle
omega = acos(dot(u1(ind),v1(ind)));

% define rotation
if isempty(omega), omega =[];end
q(ind) = axis2quat(ax,omega);


%% case 5: d1 || d2 -> rotation about (u1 x u2) x (v1 x v2)
ind = indLeft & abs(cross(d1,d2))<1e-6;
indLeft = indLeft & ~ind;

ax = cross(cross(u1(ind),u2(ind)),cross(v1(ind),v2(ind)));
ax = ax./norm(ax);

a = cross(ax,v1(ind));
a = a ./ norm(a);

b = cross(ax,u1(ind));
b = b ./ norm(b);

omega = acos(dot(a,b));

q(ind) = axis2quat(ax,omega);


%% case 6: d1 and d2 are not collinear -> rotation about d1 x d2

% roation axis
axis = cross(d1(indLeft),d2(indLeft));
axis = axis ./ norm(axis);

% compute angle
a = cross(axis,v1(indLeft));
a = a ./ norm(a);

b = cross(axis,u1(indLeft));
b = b ./ norm(b);

omega = acos(dot(a,b));

q(indLeft) = axis2quat(axis,omega);


% check function:
%
% u1 = xvector;
% u1 = yvector;
% v1 = xvector;
% v1 = yvector;
% u2 = zvector;
% u2 = xxvector;
% v2 = yvector;
%
% q = vec42quat(u1,v1,u2,v2);
%
% [q*u1,q*u2]
% 
%
% u1 = sph2vec((90-52.403)*degree,86.08*degree);
% v1 = sph2vec((90-52.422)*degree,-0.422*degree);
% u2 = sph2vec((90-53.327)*degree,47.396*degree);
% v2 = sph2vec((90-28.795)*degree,-14.590*degree);

%u1 = sph2vec((90-64.063)*degree,76.128*degree);
%v1 = sph2vec((90-40.128)*degree,-20.725*degree);
%u2 = sph2vec((90-46.812)*degree,46.977*degree);
%v2 = sph2vec((90-39.573)*degree,0.773*degree);
%

% q = rotation('Euler',20*degree,10*degree,50*degree);
% u1 = xvector;
% u2 = yvector;

% q = rotation('axis',zvector,'angle',20*degree)
% qq = rotation('map',u1,q*u1,u2,q*u2)
