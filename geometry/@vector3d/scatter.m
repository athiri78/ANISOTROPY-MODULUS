function scatter(v,varargin)
%
% Syntax
%   scatter(v)              %
%   scatter(v,data)         %
%   scatter(v,text)
%
% Input
%  v     - @vector3d
%  data  - double
%  rgb   - a list of rgb color values
%
% Options
%  Marker            - 
%  MarkerFaceColor   -
%  MarkerEdgeColor   - 
%  MarkerColor       - shortcut for the above two
%  MarkerSize        - size of the markers in pixel
%  DynamicMarkerSize - scale marker size when plot is resized
%
% Output
%
% See also

% initialize spherical plots
sP = newSphericalPlot(v,varargin{:});

for i = 1:numel(sP)

  % project data
  [x,y] = project(sP(i).proj,v,varargin{:});

  % annotations
  annotations = {};

  % check that there is something left to plot
  if all(isnan(x) | isnan(y))
    if nargout > 0
      h = [];
    end
  else

    % default arguments
    patchArgs = {'parent',sP(i).ax,...
      'vertices',[x(:) y(:)],...
      'faces',1:numel(x),...
      'facecolor','none',...
      'edgecolor','none',...
      'marker','o',...
      };

    % markerSize
    res = max(v.resolution,1*degree);
    res = get_option(varargin,'scatter_resolution',res);
    MarkerSize  = get_option(varargin,'MarkerSize',min(8,50*res));
    patchArgs = [patchArgs,{'MarkerSize',MarkerSize}]; %#ok<AGROW>

    % dynamic markersize
    if check_option(varargin,'dynamicMarkerSize') || ...
        (~check_option(varargin,'MarkerSize') && length(v)>20)
      patchArgs = [patchArgs {'tag','dynamicMarkerSize','UserData',MarkerSize}]; %#ok<AGROW>
    end
    
    % ------- colorcoding according to the first argument -----------
    if ~isempty(varargin) && isnumeric(varargin{1}) && ~isempty(varargin{1})
      
      % extract colorpatchArgs{3:end}coding
      cdata = varargin{1};
      if numel(cdata) == length(v)
        cdata = reshape(cdata,[],1);
      else
        cdata = reshape(cdata,[],3);
      end
      
      % draw patches
      h = optiondraw(patch(patchArgs{:},...
        'facevertexcdata',cdata,...
        'markerfacecolor','flat',...
        'markeredgecolor','flat'),varargin{2:end});
      
      % add annotations for min and max
      if numel(cdata) == length(v)
        annotations = {'BL',{'Min:',xnum2str(min(cdata(:)))},'TL',{'Max:',xnum2str(max(cdata(:)))}};
      end
  
      % --------- colorcoding according to nextStyle -----------------
    else
  
      % get color
      if check_option(varargin,{'MarkerColor','MarkerFaceColor'})
        mfc = get_option(varargin,'MarkerColor','none');
        mfc = get_option(varargin,'MarkerFaceColor',mfc);
      else % cycle through colors
        [ls,mfc] = nextstyle(sP(i).ax,true,true,~ishold(sP(i).ax)); %#ok<ASGLU>
      end
      mec = get_option(varargin,'MarkerEdgeColor',mfc);
  
      % draw patches
      h = optiondraw(patch(patchArgs{:},...
        'MarkerFaceColor',mfc,...
        'MarkerEdgeColor',mec),varargin{:});

    end
  end
    
  % add annotations
  sP(i).plotAnnotate(annotations{:},varargin{:})

  % set resize function for dynamic marker sizes
  try
    hax = handle(sP(i).ax);
    hListener(1) = handle.listener(hax, findprop(hax, 'Position'), ...
      'PropertyPostSet', {@localResizeScatterCallback,sP(i).ax});
    % save listener, otherwise  callback may die
    setappdata(hax, 'dynamicMarkerSizeListener', hListener);
  catch
    %disp('some Error!');
  end

  % plot labels
  if check_option(varargin,{'text','label','labeled'})
    text(v,get_option(varargin,{'text','label'}),'parent',sP(i).ax,varargin{:});
  end

  
  
end


end


% ---------------------------------------------------------------
function localResizeScatterCallback(h,e,hax)
% get(fig,'position')

hax = handle(hax);

% ------------ adjust label positions ----------------
t = findobj(hax,'Tag','addMarkerSpacing');

% get markerSize
markerSize = get(findobj(hax,'type','patch'),'MarkerSize');
if isempty(markerSize)
  markerSize = 0;
elseif iscell(markerSize)
  markerSize = [markerSize{:}];
end

markerSize = max(markerSize);


for it = 1:length(t)
  
  xy = get(t(it),'UserData');
  set(t(it),'unit','data','position',[xy,0]);
  set(t(it),'unit','pixels');
  xy = get(t(it),'position');
  if isappdata(t(it),'extent')
    extend = getappdata(t(it),'extent');
  else
    extend = get(t(it),'extent');
    setappdata(t(it),'extent',extend);
  end
  margin = get(t(it),'margin');
  xy(2) = xy(2) - extend(4)/2 - margin - markerSize/2 + 2;
  if isnumeric(get(t(it),'BackgroundColor')), xy(2) = xy(2) - 5;end
  set(t(it),'position',xy);
  set(t(it),'unit','data');
  %get(t(it),'position')
end

% ------------- scale scatterplots -------------------------------
u = findobj(hax,'Tag','dynamicMarkerSize');

if isempty(u), return;end

p = get(u(1),'parent');
unit = get(p,'unit');
set(p,'unit','pixel')
pos = get(p,'position');
l = min([pos(3),pos(4)]);
if l < 0, return; end 

for i = 1:length(u)
  d = get(u(i),'UserData');
  o = get(u(i),'MarkerSize');
  %n = l/350 * d;
  n = l/250 * d;
  if abs((o-n)/o) > 0.05, set(u(i),'MarkerSize',n);end
  
end

set(p,'unit',unit);

end
