function display(s)
% standard output

% check whether crystal or specimen symmetry
if isempty(s.mineral) && length(s)<=4 && all(s.axis == [xvector,yvector,zvector])
  
  disp(' ');
  disp([inputname(1) ' = ' s.name ' specimen ' doclink('symmetry_index','symmetry') ' (size: ' int2str(numel(s)) ')']);
  disp(' ');
  
  return
end


disp(' ');
disp([inputname(1) ' = crystal ' doclink('symmetry_index','symmetry') ' (size: ' int2str(numel(s)) ')']);

disp(' ');

props = {}; propV = {};

% add mineral name if given
if ~isempty(s.mineral)
  props{end+1} = 'mineral'; 
  propV{end+1} = s.mineral;
end

% add symmetry
props{end+1} = 'symmetry'; 
propV{end+1} = [s.name ' (' s.laue ')'];

% add axis length
if ~any(strcmp(s.laue,{'m-3','m-3m'}))
  props{end+1} = 'axes length'; 
  propV{end+1} = option2str(vec2cell(get(s,'axesLength')));
end


% add axis angle
if any(strcmp(s.laue,{'-1','2/m','-3m','-3'}))
  props{end+1} = 'axes angle';
  angles = get(s,'axesAngle');
  propV{end+1} = [num2str(angles(1)) '°, ' num2str(angles(2)) '°, ' num2str(angles(3)) '°'];
end

% add reference frame
if any(strcmp(s.laue,{'-1','2/m','-3m','-3'}))
  props{end+1} = 'reference frame'; 
  propV{end+1} = option2str(get(s,'convention'));    
end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

disp(' ');

