function sP = newSphericalPlot(v,varargin)
% split plot in upper and lower hemisphere
%
% 1: axis given -> no sphericalRegion stored -> compute sphericalRegion -> finish
% 2: axis is hold and has sphericalRegion -> use multiplot
% 3: new multiplot

% case 1: predefined axis
% -----------------------
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
  
  % axis is already a spherical plot
  if isappdata(ax,'sphericalPlot') && ishold(ax)
  
    sP = getappdata(ax,'sphericalPlot');
    
  else % set up a new spherical axes if required
    
    % extract spherical region
    sR = getPlotRegion(v,varargin{:});
    
    % extract projection
    proj = getProjection(sR,varargin{:});
    
    % create a new spherical plot
    sP = sphericalPlot(ax,proj(1),varargin{:});
            
  end    
  return;
end
  
% create a new mtexFigure or get a reference to it
mtexFig = mtexFigure(varargin{:});

if isempty(mtexFig.children)

  % get spherical region
  sR = getPlotRegion(v,varargin{:});
  
  % extract projection(s)
  % this might return two projections for upper and lower hemisphere
  proj = getProjection(sR,varargin{:});
  
  for i = 1:numel(proj)    
    
    % create a new axis
    ax = mtexFig.nextAxis;
    
    % create a new spherical plot
    sP(i) = sphericalPlot(ax,proj(i),varargin{:});         %#ok<AGROW>
    
  end
        
else % add to or overide existing axes
    
  for i = 1:numel(mtexFig.children)
    
    sP(i) = getappdata(mtexFig.children(i),'sphericalPlot'); %#ok<AGROW>
    
  end
  
end

end

% ---------------------------------------------------------
function sR = getPlotRegion(varargin)
% returns spherical region to be plotted

% default values from the vectors to plot
if isa(varargin{1},'vector3d'),
  varargin{1} = varargin{1}.region(varargin{2:end});
end
sR = getClass(varargin,'sphericalRegion',sphericalRegion);

% check for simple options
if check_option(varargin,'complete')
  sR = sphericalRegion;
end
if check_option(varargin,'upper')
  sR = sR.restrict2Upper;
elseif check_option(varargin,'lower')
  sR = sR.restrict2Lower;
end

% extract antipodal
sR.antipodal = check_option(varargin,'antipodal') || varargin{1}.antipodal;

% for antipodal symmetry reduce to halfsphere
if sR.antipodal && sR.isUpper && sR.isLower &&...
    ~check_option(varargin,'complete')
  sR = sR.restrict2Upper;
end

end
% ---------------------------------------------------------
function proj = getProjection(sR,varargin)

switch get_option(varargin,'projection','earea')
  case 'plain'
    
    proj = plainProjection(sR);
    
   case {'stereo','eangle'} % equal angle
    
     proj = eangleProjection(sR);

  case 'edist' % equal distance
    
    proj = edistProjection(sR);

  case {'earea','schmidt'} % equal area

    proj = eareaProjection(sR);
        
  case 'orthographic'

    proj = orthographicProjection(sR);
    
  otherwise
    
    error('Unknown Projection!')
    
end

if ~isa(proj,'plainProjection') && sR.isUpper && sR.isLower  
  proj = [proj,proj];
  proj(1).sR = proj(1).sR.restrict2Upper;
  proj(2).sR = proj(2).sR.restrict2Lower;
end


end
