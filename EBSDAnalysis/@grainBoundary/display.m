function display(gB,varargin)
% standard output
%
%  id  | mineralLeft | mineralRight
% ---------------------------------
%
% #ids | mineralLeft | mineralRight
% ---------------------------------

disp(' ');
h = doclink('grainBoundary_index','grainBoundary');
if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;
disp([h ' ' docmethods(inputname(1))])

% empty grain boundary set 
if isempty(gB)
  disp('  grain boundary is empty!')
  return
end

disp(' ')

pairs = allPairs(1:numel(gB.phaseMap));
%pairs(1) = [];

% ebsd.phaseMap
matrix = cell(size(pairs,1),3);


for ip = 1:size(pairs,1)

  matrix{ip,1} = int2str(nnz(gB.hasPhaseId(pairs(ip,1)) & gB.hasPhaseId(pairs(ip,2))));
  
  % phases
  if ischar(gB.allCS{pairs(ip,1)})
    matrix{ip,2} = gB.allCS{pairs(ip,1)};
  else
    matrix{ip,2} = gB.allCS{pairs(ip,1)}.mineral;
  end
  if ischar(gB.allCS{pairs(ip,2)})
    matrix{ip,3} = gB.allCS{pairs(ip,2)};
  else
    matrix{ip,3} = gB.allCS{pairs(ip,2)}.mineral;
  end

end

cprintf(matrix,'-L',' ','-Lc',...
  {'Segments' 'mineral 1' 'mineral 2'},'-d','  ','-ic',true);

%disp(' ');
%disp(char(dynProp(gB.prop)));
%disp(' ');
