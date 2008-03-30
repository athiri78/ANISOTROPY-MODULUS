function handles = s2crystal( handles, cs, ss )

csname = strmatch(Laue(cs),symmetries);
set(handles.crystal,'value',csname(1));
 
% set axes
[c, angle] = get_axisangel( cs );
 
for k=1:3 
  set(handles.axis{k},'String',c(k)); 
  set(handles.angle{k},'String',angle{k});
end
% set specimen symmetry
ssname = strmatch(Laue(ss),symmetries);
set(handles.specime,'value',ssname(1));

set([handles.axis{:} handles.angle{:}], 'Enable', 'on');

if ~strcmp(Laue(cs),{'-1','2/m'})
  set([handles.angle{:}], 'Enable', 'off');
end

if any(strcmp(Laue(cs),{'m-3m','m-3'})),
  set([handles.axis{:}], 'Enable', 'off');
end