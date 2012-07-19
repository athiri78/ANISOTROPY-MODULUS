function h = plotUnitCells(xy,d,unitCell,varargin)


if ~isempty(unitCell)
  
  [unitCell(:,1), unitCell(:,2)] = fixMTEXscreencoordinates(unitCell(:,1),unitCell(:,2),varargin{:});
  
  type = get_flag(varargin,{'unitcell','points','measurements'},'unitcell');
  
else
  
  type = 'points';
  
end

[xy(:,1), xy(:,2), lx, ly]     = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});

obj.FaceVertexCData = d;

if check_option(varargin,{'transparent','translucent'})
  
  s = get_option(varargin,{'transparent','translucent'},1,'double');
  
  if size(d,2) == 3 % rgb
    obj.FaceVertexAlphaData = s.*(1-min(d,[],2));
  else
    obj.FaceVertexAlphaData = s.*d./max(d);
  end
  obj.AlphaDataMapping = 'none';
  obj.FaceAlpha = 'flat';
  
end
obj.FaceColor = 'flat';
obj.EdgeColor = 'none';
obj.HitTest = 'off'; % Improve speed of ginput(...)

switch lower(type)
  case 'unitcell'
    
    % generate patches
    [obj.Vertices obj.Faces] = generateUnitCells(xy,unitCell,varargin{:});
    
  case {'points','measurements'}
    
    obj.Vertices = xy;
    obj.Faces    = (1:size(xy,1))';
    
    obj.FaceColor = 'none';
    obj.EdgeColor = 'flat';
    obj.Marker = '.';
    obj.MarkerFaceColor = 'flat';
    
end

h = optiondraw(patch(obj),varargin{:});

% cosmetics
xlabel(lx); ylabel(ly);



