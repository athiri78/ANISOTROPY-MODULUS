function  drawNow(mtexFig, varargin)

if check_option(varargin,'doNotDraw'), return;end

set(mtexFig.children,'units','pixel');

% update children to be only the axes of mtexFig
mtexFig.children = flipud(findobj(mtexFig.parent,'type','axes',...
  '-not','tag','Colorbar','-and','-not','tag','legend'));

% this seems to be necesarry to get tight inset right
updateLayout(mtexFig);

% compute surounding box of each axis in pixel
mtexFig.tightInset = calcTightInset(mtexFig);

% determine prelimary figure size
if check_option(varargin,'position')
  
  position = get_option(varargin,'position');
  figSize = position(3:4);
  
  if any(strcmpi(position,{'auto','large','normal','small'}))
    screenExtend = get(0,'MonitorPositions');
    
    mtexFig.keepAspectRatio = true;
    figSize = screenExtend(1,3:4) - [0,120]; % consider only the first monitor

    switch position
      case 'auto'
        n = numel(mtexFig.children);
        figSize = figSize .* min([1 1],[n/4, (1 + (n>4))/2]);
      case 'large'
        figSize = figSize .* 0.9;
      case 'normal'
        figSize = figSize .* 0.5;
      case 'small'
        figSize = figSize .* 0.25;
    end
  end
  
else

  position = get(mtexFig.parent,'Position'); 
  figSize = position(3:4);
  
end

figSize = figSize - 2*mtexFig.outerPlotSpacing;

% compute layout
[mtexFig.ncols,mtexFig.nrows] = calcPartition(mtexFig,figSize);
[mtexFig.axisWidth,mtexFig.axisHeight] = calcAxesSize(mtexFig,figSize);

% resize figure
if exist('screenExtend','var')
  width = mtexFig.axesWidth;
  height = mtexFig.axesHeight;
  position = [(screenExtend(3)-width)/2,(screenExtend(4)-height)/2,width,height];
end

% draw layout
set(mtexFig.parent,'ResizeFcn',[]);
set(mtexFig.parent,'position',position);
updateLayout(mtexFig);
set(mtexFig.parent,'ResizeFcn',@(src,evt) updateLayout(mtexFig));

% update colorrange
if check_option(varargin,'colorrange')
  mtexFig.CLim(get_option(varargin,'colorrange'));
end

% update scale bars
for i = 1:numel(mtexFig.children)
  mP = getappdata(mtexFig.children(i),'mapPlot');
  if ~isempty(mP), mP.micronBar.update; end  
end

end
