function plotIPDF(odf,r,varargin)
% plot inverse pole figures
%
% Input
%  odf - @ODF
%  r   - @vector3d specimen directions
%
% Options
%  RESOLUTION - resolution of the plots
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

argin_check(r,'vector3d');

% get fundamental sector for the inverse pole figure
sR = fundamentalSector(odf.CS,varargin{:});

% plotting grid
h = plotS2Grid(sR,varargin{:});

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

for i = 1:length(r)
  if i>1, mtexFig.nextAxis; end

  % compute inverse pole figures
  p = ensureNonNeg(pdf(odf,h,r(i),varargin{:}));

  % plot
  h.smooth(p,'parent',mtexFig.gca,'doNotDraw',varargin{:});
  title(mtexFig.gca,char(r(i)),'FontSize',getMTEXpref('FontSize'));

end


if isNew % finalize plot
  
  mtexFig.drawNow('autoPosition');
  setappdata(gcf,'inversePoleFigureDirection',r);
  setappdata(gcf,'CS',odf.CS);
  setappdata(gcf,'SS',odf.SS);
  set(gcf,'tag','ipdf');
  set(gcf,'Name',['Inverse Pole Figures of ',inputname(1)]);

  mtexFig.drawNow('autoPosition');

end

% --------------- tooltip function ------------------------------
function txt = tooltip(varargin)

[h_local,value] = getDataCursorPos(mtexFig);

h_local = Miller(h_local,getappdata(mtexFig.parent,'CS'),'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end

