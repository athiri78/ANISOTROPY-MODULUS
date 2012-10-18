function varargout = scatter(m,varargin)
% plot Miller indece
%
%% Input
%  m  - Miller
%
%% Options
%  ALL       - plot symmetrically equivalent directions
%  antipodal - include antipodal symmetry
%  labeled   - plot Miller indice as label
%  label     - plot user label
%
%% See also
% vector3d/scatter

%% preprocess input

% new figure if needed
if ~ishandle(m), newMTEXplot;end

% get axis hande
[ax,m,varargin] = getAxHandle(m,varargin{:});

% extract data
if numel(varargin) > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1})
  cdata = varargin{1};
  varargin(1) = [];
else
  cdata = [];
end
    
% symmetrise if needed
if check_option(varargin,{'ALL','symmetrised','FundamentalRegion'})
  
  % first dimension cs - second dimension m
  m = symmetrise(m,varargin{:});
  varargin = [varargin,{'removeAntipodal'}];
  
  % symmetrise data
  if ~isempty(cdata)
    cdata = repmat(cdata(:)',size(m,1),1);
  end
end

% restrict to fundamental region
if check_option(varargin,'fundamentalRegion') && ~check_option(varargin,'complete')
  
  % get fundamental region
  [maxTheta,maxRho,minRho] = getFundamentalRegionPF(m.CS,varargin{:});
  varargin = [{'minRho',minRho,'maxRho',maxRho,'maxTheta',maxTheta},varargin];

end

  
%% plot

if size(m,2) > 20 || ~isempty(cdata)

  % write back cdata
  if ~isempty(cdata), varargin=[{cdata},varargin];end
  
  % plot them all with the same color
  [varargout{1:nargout}] = scatter(ax{:},m.vector3d,varargin{:});
    
else % if there are only a few points plots them with different colors

  % store hold status
  washold = getHoldState(ax{:});

  % plot
  hold all
  for i = 1:size(m,2)
    scatter(ax{:},unique(m.vector3d(:,i)),varargin{:});
  end

  % revert old hold status
  hold(ax{:},washold); 
end
