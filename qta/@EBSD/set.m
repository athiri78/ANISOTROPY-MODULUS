function ebsd = set(ebsd,vname,value,varargin)
% set object variable to value
%
%% Syntax
%  ebsd = get(ebsd,'vname',value)   -
%  ebsd = get(ebsd,'CS',symmetry)   - changes the crystal symmetry
%  ebsd = get(ebsd,'newfield',value)  - adds |'newfield'| as an EBSD property, e.g. like MAD..
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  phase - phase to consider
%  CS | SS - modify @symmetry
%  X - change spatial coordinates
%  orientations - set @orientations. Not recommend, should use the
%  [[EBSD.EBSD.html,EBSD]] constructor
%
%% Output
% ebsd - the modified @EBSD object
%
%% See also
% EBSD/get

if any(strcmp(vname,fields(ebsd)))
  
  if strcmp(vname,'CS')
    notIndexedPhase = ebsd.phaseMap(cellfun('isclass',ebsd.CS,'char'));
    notIndexed = ismember(ebsd.phaseMap,notIndexedPhase);
    if numel(value) == nnz(ebsd.phaseMap) || numel(value) == 1
      value(~notIndexed) = value;
      value(notIndexed) = {'not indexed'};
    else
      error('The number of symmetries specified is less than the largest phase id.')
    end
  end
  
  ebsd.(vname) = value;
  
elseif isfield(ebsd.options,vname)
  
  if isempty(value)
    
    ebsd.options = rmfield( ebsd.options,vname);
    
  else
    
    ebsd.options.(vname) = value;
    
  end
  
else
  
  ebsd.options.(vname) = value;
  
end

