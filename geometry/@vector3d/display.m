function display(v)
% standard output

if max(abs(v.x)) < 1e-14, v.x = zeros(size(v.x));end
if max(abs(v.y)) < 1e-14, v.y = zeros(size(v.y));end
if max(abs(v.z)) < 1e-14, v.z = zeros(size(v.z));end

disp([inputname(1) ' = "vector3d"']);
disp('  x = ');
disp(v.x);
disp('  y = ');
disp(v.y);
disp('  z = ');
disp(v.z);
