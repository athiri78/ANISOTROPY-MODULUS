function display(q)
% standart output

disp([inputname(1) ' = "Quaternion": (size: ' int2str(size(q.b)) ')']);
disp('  a = ');
disp(n2str(q.a));
disp('  b = ');
disp(n2str(q.b));
disp('  c = ');
disp(n2str(q.c));
disp('  d = ');
disp(n2str(q.d));
