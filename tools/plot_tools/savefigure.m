function savefigure(fname,varargin)
% save figure as grafik file
%
%% Description
% This function is supposed to produce cropped, publication ready image
% files from your plots. The format of the file is determined by the
% extension of the filename. 
%
%% Syntax
% savefigure(fname,<options>)
%
%% Input
%  filename - string
%  

% no file name given select from dialog
if nargin == 0, 
  [name,pathstr] = uiputfile({'*.pdf;*.eps;*.ill','Vector Image File'; ...
    '*.jpg;*.tif;*.png;*.gif;*.bmp;*pgm;*.ppm','Bitmap Image Files';...
    '*.*','All Files' },'Save Image','newfile.pdf');
  if isequal(name,0) || isequal(pathstr,0), return;end
  fname = [pathstr,name];
end

% seperate extension
[~, ~, ext] = fileparts(fname);

% resize figure to look good
ounits = get(gcf,'Units');
set(gcf,'PaperPositionMode','auto');
set(gcf,'Units','pixels');
pos = get(gcf,'Position');
si = get(gcf,'UserData');
	
if (length(si) == 2) && isempty(findall(gcf,'tag','Colorbar'))
  pos([3,4]) = si;
	set(gcf,'Position',pos);
end

set(gcf,'Units','centimeters');
pos = get(gcf,'PaperPosition');
set(gcf,'PaperUnits','centimeters','PaperSize',[pos(3),pos(4)]);
set(gcf,'Units',ounits);


% try to switch to painters mode for vector formats
% by converting RGB graphics to indexed graphics
if any(strcmpi(ext,{'.eps','.pdf'})) && ~strcmpi(get(gcf,'renderer'),'painters') ...
    && isRGB

  try
    convertFigureRGB2ind;
    set(gcf,'renderer','painters');            
  catch
    warning('MTEX:export','Unable to switch to painter''s mode. You may need to export to png or jpg');
  end

end
  
% for bitmap formats try to use export fig
if ~(ismac || ispc) || all(~strcmpi(ext,{'.eps','.pdf'}))
  try
    oldColor = get(gcf,'color');
    set(gcf,'color','none');
    export_fig(gcf,fname,'-m1.5');
    %export_fig(gcf,fname);
    if exist(fname,'file'), 
      set(gcf,'color',oldColor);
      return;
    end
  catch
  end
  set(gcf,'color',oldColor);
end



switch lower(ext(2:end))

case {'eps','ps'}
  flags = {'-depsc'};  
case 'ill'
  flags = {'-dill'};  
case {'pdf'}
  flags = {'-dpdf'};
case {'jpg','jpeg'}
  flags = {'-r600','-djpeg'};  
  set(gcf,'renderer','zbuffer');
case {'tiff'}
  flags = {'-r500','-dtiff'};
case {'png'}
  flags = {'-r500','-dpng'};
case {'bmp'}
  flags = {'-r500','-dbmp'};
otherwise
  saveas(gcf,fname);
  return
end

printOptions = delete_option(varargin,{'crop','pdf'});
print(fname,flags{:},printOptions{:});

if check_option(varargin,'pdf')
  unix(['epstopdf' ' ' fname]);
  fname = strrep(fname,'eps','pdf');
  unix(['pdfcrop' ' ' fname ' ' fname]);
end

if check_option(varargin,'crop')
  
  unix(['pdfcrop' ' ' fname ' ' fname]);
  
end

end


% ------------------------------------------------------------------

function convertFigureRGB2ind

cmaplength = 1024;
globmap = [1,1,1]; % white for NaN values

ax = findall(gcf,'type','axes');

for iax = 1:numel(ax)
  
  childs = findobj(ax(iax),'-property','CData');
    
  if isempty(childs), continue;end
    
  CData = get(childs,'CData');
  
  CData = ensurecell(CData);
  
  % take only RGB values
  ind = cellfun(@(x) size(x,3)==3,CData);
  childs = childs(ind);
  CData = CData(ind);
  
  % cat Data into one vector
  combined = cat(1,CData{:});
  
  if size(combined,3) == 1, continue;end
  
  % convert to index data
  [data, map] = rgb2ind(combined, cmaplength);
  
  % NaN values should be white
  ind = any(isnan(combined),3);
  data(ind) = 0;
    
  % shift data to fit globmap
  data(~ind) = data(~ind) + size(globmap,1);
  globmap = [globmap;map]; %#ok<AGROW>
  
  pos = 1;
  for ind = 1:numel(CData)
    
    s = size(CData{ind});
    set(childs(ind),'CData',...
      reshape(double(data(pos:pos+prod(s(1:2))-1)),s(1:2)));
    pos = pos + prod(s(1:2));
  end
end

%set new colormap
set(gcf,'colormap',globmap);
%setcolorrange('equal');

end

%%

function out = isRGB

out = false;

ax = findall(gcf,'type','axes');
childs = findobj(ax,'-property','CData');
    
if isempty(childs), return;end
    
CData = ensurecell(get(childs,'CData'));
    
out = any(cellfun(@(x) size(x,3)==3,CData));

end

%%

function convertAxisLabel2text

ax = findall(gcf,'type','axes');

for iax = 1:numel(ax)
  
  xLabel = get(ax(iax),'XTickLabel');
  x = get(ax(iax),'XTick');
  if ~isempty(xLabel) && ~isempty(x)
    y = ylim(ax(iax));
    text(ax(iax),x,repmat(y(1),size(x)),...
      'FontName',get(ax(iax),'FontName'),...
      'FontAngle',get(ax(iax),'FontAngle'),...
      'FontWeight',get(ax(iax),'FontWeight'),...
      'interpreter','tex');
    set(ax(iax),'XTickLabel',[]);
  end    
end
  
end