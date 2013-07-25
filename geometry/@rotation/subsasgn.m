function r = subsasgn(r,s,b)
% overloads subsasgn

if isempty(r)
  r = b;
  r.a = [];
  r.b = [];
  r.c = [];
  r.d = [];
  r.i = [];
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  builtin('subsasgn',subsref(r,s(1)),s(2:end),b); end
      
    if isempty(b)
      r.a = subsasgn(r.a,s(1),[]);
      r.b = subsasgn(r.b,s(1),[]);
      r.c = subsasgn(r.c,s(1),[]);
      r.d = subsasgn(r.d,s(1),[]);
      r.i = subsasgn(r.i,s(1),[]);
    else
      b = rotation(b);
      r.a = subsasgn(r.a,s(1),b.a);
      r.b = subsasgn(r.b,s(1),b.b);
      r.c = subsasgn(r.c,s(1),b.c);
      r.d = subsasgn(r.d,s(1),b.d);
      r.i = subsasgn(r.i,s(1),b.i);
    end
  otherwise
      
    r =  builtin('subsasgn',r,s,b);
      
end

end
