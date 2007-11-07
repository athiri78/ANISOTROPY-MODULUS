function q = times(q1,q2)
% implements quaternion .* quaternion and quaternion .* vector3d 
%% Input
%  q1 - @quaternion
%  q2 - @quaternion | @vector3d
%
%% Output
%  @quaternion | @vector3d

if isa(q1,'quaternion') && isa(q2,'quaternion')
    q = quaternion(q1.a .* q2.a - q1.b .* q2.b - q1.c .* q2.c - q1.d .* q2.d,...
		q1.a .* q2.b + q1.b .* q2.a + q1.c .* q2.d - q2.c .* q1.d,...
		q1.a .* q2.c + q1.c .* q2.a + q1.d .* q2.b - q2.d .* q1.b,...
		q1.a .* q2.d + q1.d .* q2.a + q1.b .* q2.c - q2.b .* q1.c);
elseif isa(q1,'quaternion') && isa(q2,'double')
    q = quaternion(q1.a .* q2,q1.b .* q2,q1.c .* q2,q1.d .* q2);
elseif isa(q2,'quaternion') && isa(q1,'double')
    q = quaternion(q2.a .* q1,q2.b .* q1,q2.c .* q1,q2.d .* q1);
elseif isa(q1,'quaternion') && isa(q2,'vector3d')

  [x,y,z] = double(q2);
  n = q1.b.^2 + q1.c.^2 + q1.d.^2;
  s = x.*q1.b + y.*q1.c + z.*q1.d;
    
  nx = 2*q1.a.*(q1.c.* z - y.*q1.d) + 2*s.*q1.b + (q1.a.^2 - n).*x;
  ny = 2*q1.a.*(q1.d.* x - z.*q1.b) + 2*s.*q1.c + (q1.a.^2 - n).*y;
  nz = 2*q1.a.*(q1.b.* y - x.*q1.c) + 2*s.*q1.d + (q1.a.^2 - n).*z;
  q = vector3d(nx,ny,nz);
        
elseif isa(q1,'quaternion') && size(q2,1)==3    % zweites Element ist ein Vektor
    qq = quaternion(0,q2(1,:),q2(2,:),q2(3,:));
    q3 = q1 .* qq .* q1';
    q = [q3.b;q3.c;q3.d];
else 
    error('wrong type of arguments');
end

