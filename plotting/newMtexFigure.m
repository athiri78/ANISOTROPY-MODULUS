function [mtexFig,newFigure] = newMtexFigure(varargin)
% 

% check hold state
newFigure = ~isappdata(gcf,'mtexFig') || check_option(varargin,'newFigure') || ...
  (strcmp(getHoldState,'off') && ~check_option(varargin,{'hold','parent'}));

% check tag
if ~newFigure && check_option(varargin,'ensureTag') && ...
    ~any(strcmpi(get(gcf,'tag'),get_option(varargin,'ensureTag')))
  newFigure = true;
  warning('MTEX:newFigure','Plot type not compatible to previous plot! I''going to create a new figure.');
end

% check appdata
ad = get_option(varargin,'ensureAppdata');
if ~newFigure
  try
    for i = 1:length(ad)
      if ~isappdata(gcf,ad{i}{1}) || (~isempty(ad{i}{2}) && ~all(getappdata(gcf,ad{i}{1}) == ad{i}{2}))
        newFigure = true;
        warning('MTEX:newFigure','Plot properties not compatible to previous plot! I''going to create a new figure.');
        break
      end
    end
  catch %#ok<CTCH>
    newFigure = true;
  end
end

% set up a new figure
if newFigure

  if check_option(varargin,'parent')
  
    mtexFig.gca = get_option(varargin,'parent');
    newFigure = false;
    
  else
    
    mtexFig = mtexFigure(varargin{:});
  
    % set tag
    if check_option(varargin,'ensureTag','char')
      set(gcf,'tag',get_option(varargin,'ensureTag'));
    end

    % set appdata
    if check_option(varargin,'ensureAppdata')
      for i = 1:length(ad)
        setappdata(gcf,ad{i}{1},ad{i}{2})
      end
    end
  end
else % use an existing figure
  
  % get existing mtexFigure
  mtexFig = getappdata(gcf,'mtexFig');
  
  holdState = getHoldState;
  % distribute hold state over all axes
  for i=1:numel(mtexFig.children)
    hold(mtexFig.children(i),holdState);
  end
  
  % set current axis
  if check_option(varargin,'parent')
    mtexFig.currentAxes = get_option(varargin,'parent');
  else
    mtexFig.currentId = 1;
  end
end

end
