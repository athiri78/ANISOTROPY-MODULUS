classdef scaleBar < handle
% Inserts a scale bar on the current ebsd or grain map.
%
% Syntax
%   hg = scaleBar(ebsd, scanunits, ...)
%
% Input
%  ebsd      - an mtex ebsd or grain object
%  scanunits - units of the xy coordinates of the ebsd scan (e.g., 'um')
%
% Output
%  oval  - output value 
%  ounit - output unit
%
% Options
%  BACKGROUNDCOLOR - background color (ColorSpec)
%  BACKGROUNDALPHA - background transparency (scalar 0<=a<=1)

%
% Example
%  Use a scale bar on the aachen mtexdata.
%
%   mtexdata aachen
%   plot(ebsd)
%   scaleBar(ebsd,'um','BackgroundColor','k','LineColor','w', ...
%                 'Border','off','BackgroundAlpha',0.6,'Location','nw')
%
% Bugs/Issues
%  [1] Using the hardware OpenGL renderer can sometimes cause the text not
%  to appear on the scale bar. This can usually be fixed by adding the line
%
%   opengl software
%
%  _Before_ the call to scaleBar().
%
%  [2] The font and the bounding box do not scale with the figure window.
%  Therefore, the desired figure window size needs to be set before the
%  call to scaleBar().
%
% Authors
%  Eric Payton, eric.payton@bam.de
%  Philippe Pinard, pinard@gfe.rwth-aachen.de 
%
% Revision History
%  2012.07.17 EJP - First version submitted for mtex commit. 
%  2012.07.27 EJP - Added option for specifying scale bar lengths.

properties (Access = private)
  hgt
  shadow
  txt
  ruler
end

properties (SetObservable)
  backgroundColor = 'k'    % background color (ColorSpec)
  backgroundAlpha = 0.6    % background transparency (scalar 0<=a<=1)
  scanUnit        = 'um'   % units of the xy coordinates of the ebsd scan (e.g., 'um')
  lineColor       = 'w'    % border color and text color (ColorSpec)
  border          = 'off ' % controls whether the box has a border ('on', 'off')
  borderWidth     = 2      % width of border (scalar)
  location        = 'sw'   % location of the scale bar ('nw,'ne','sw','se', or [x,y] coordinate vector (len(vector)==2)
  length          = NaN    % desired scale bar length or array of allowable lengths
end
  
methods

  function sB = scaleBar(mP,scanUnit,varargin)
    
    sB.scanUnit = scanUnit;
    sB.hgt = hgtransform('parent',mP.ax);
    sB.txt = text('parent',sB.hgt,'string','1mm','position',[NaN,NaN],...
      'FontSize',getMTEXpref('FontSize'));
    sB.shadow = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN NaN]);
    sB.ruler = patch('parent',sB.hgt,'Faces',1,'Vertices',[NaN NaN NaN]);
    
  end
  
  function update(sB)
    
    % get axes orientation
    ax = get(sB.hgt,'parent');
    [el,az] = view(ax);
    xDir = mod((-1)^(az<0) * round(el / 90),4); % E-S-W-N is 0 1 2 3
    yDir = mod(xDir - round(az / 90),4); % E-S-W-N is 0 1 2 3
    
    % get extend
    dx = xlim(ax); dy = ylim(ax);
    if any(xDir == [1,2]), dx= fliplr(dx); end
    if any(yDir == [1,2]), dy= fliplr(dy); end
    if mod(xDir,2), [dx,dy] = deal(dy,dx); end
        
    % Find the range in meters for later determination of magnitude
    % We do this so that we never display 10000 nm and always something like
    % 10 microns. Also, the correct choice of units will avoid decimals.
    [sBLength, sBUnit, factor] = switchUnit(0.3*abs(diff(dx)), sB.scanUnit);   
    if strcmpi(sBUnit,'um'), sBUnit = '\mum';end
    
    % we would like to have SBlength beeing a nice number
    goodValues = [1 2 5 10 15 20 25 50 75 100 125 150 200 500 750]; % Possible values for scale bar length  
    [~,ind] = min(abs(sBLength-goodValues));
    sBLength = goodValues(ind);
    rulerLength = sBLength * factor * sign(diff(dx));

    % A gap around the bar of 1% of bar length looks nice
    set(sB.txt,'position',[dx(1),dy(1)])
    textHeight = get(sB.txt, 'Extent');
    textHeight = textHeight(4-mod(xDir,2)) * sign(diff(dy));
    gapY = textHeight/3;
    gapX = abs(gapY) * sign(diff(dx));

    % Box position
    boxWidth = rulerLength + 2.0 * gapX;
    boxx = dx(1) + gapX;
    boxy = dy(1) + gapY;
        
    % Make bounding box. The z-coordinate is used to put the box under the
    % line.
    verts = [boxx, boxy, 0.1;
      boxx, boxy +  3*gapY + textHeight, 0.1;
      boxx + boxWidth, boxy + 3*gapY + textHeight, 0.1;
      boxx + boxWidth, boxy, 0.1];
    set(sB.shadow,'Vertices', cP(verts), ...
      'Faces', [1 2 3 4], ...
      'FaceColor', sB.backgroundColor , 'EdgeColor', 'none', ...
      'LineWidth', 1, 'FaceAlpha', sB.backgroundAlpha);
    
    % update text
    set(sB.txt,'string',[num2str(sBLength) ' ' sBUnit],'HorizontalAlignment', 'Center',...
      'VerticalAlignment', 'bottom','color','w',...
      'Position', cP([boxx+boxWidth/2,boxy+2.5*gapY,0.2]));

    % Create line as a patch. The z-coordinate is used to layer the patch over
    % top of the bounding box.
    set(sB.ruler,'Vertices',cP([boxx+gapX, boxy+gapY, 0.2; ...
      boxx + gapX, boxy+2*gapY, 0.2; ...
      boxx + gapX + rulerLength, boxy + 2*gapY, 0.2; ...
      boxx + gapX + rulerLength, boxy + gapY, 0.2]), ...
      'Faces',[1 2 3 4], 'FaceColor','w', 'FaceAlpha',1);
    
    function pos = cP(pos)
      % interchange x and y if needed
      if mod(xDir,2), pos(:,[1,2]) = pos(:,[2,1]); end
      pos(:,3) = (-1)^(az<0) * pos(:,3);
    end
    
  end
     
end
  
end

