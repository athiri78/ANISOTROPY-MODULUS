function q = axis2quat(x,y,z,omega)
% rotational axis, roational angle to Quaternion
%
%% Decription
%
% defines a rotation by a rotational axis and a roational angle
%
%% Syntax
% q = achs2quat(x,y,z,omega)
% q = achs2quat(v,omega)
%
%% Input
%  x,y,z - rotational axis (double)
%  v     - rotational axis (@vector3d)
%  omega - rotational angle
%% Output
%  q - @quaternion
%% See also
%  quaternion/quaternion euler2quat Miller2quat vec42quat hr2quat idquaternion 

if nargin == 4
    l = sqrt(x.^2+y.^2+z.^2); % normalization
    a = cos(omega/2);
    b = sin(omega/2).*x ./ l;
    c = sin(omega/2).*y ./ l;
    d = sin(omega/2).*z ./ l;
    q = quaternion(a,b,c,d);
elseif isa(x,'vector3d')
    q = quaternion(cos(y/2),sin(y/2).* x .* (1./norm(x)));
else
    error('first argument should be vector3d and second the angle');
end
