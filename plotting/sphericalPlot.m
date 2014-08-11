classdef sphericalPlot < handle
  %sphericalProjection
  
  properties
    proj = sphericalProjection
    boundary %
    grid     %
    ticks    %
    ax       %
    parent   % the figure that contains the spherical plot
    TL       %
    TR       %
    BL       %
    BR       %
  end
  
  properties (Dependent = true)
    sphericalRegion % spherical region
    antipodal       % antipodal symmetry
  end
  
  methods
    
    function sP = sphericalPlot(ax,proj,varargin)
  
      if nargin == 0, return;end
      
      % maybe there is already a spherical plot
      if isappdata(ax,'sphericalPlot') && ~ishold(ax)
        sP = getappdata(ax,'sphericalPlot');
        return
      end
      
      sP.ax = ax;
      sP.parent = get(ax,'parent');
      sP.proj = proj;
      setappdata(ax,'sphericalPlot',sP);
      
      % store hold status
      washold = getHoldState(ax);
            
      if isa(sP.proj,'plainProjection')
      
        % boundary
        bounds = sP.sphericalRegion.polarRange / degree;
        axis(ax,'on');
        set(ax,'box','on');
        
        % grid
        sP.plotPlainGrid(varargin{:});
        
      else
        
        % plot boundary
        sP.boundary = sP.sphericalRegion.plot('parent',ax);
              
        sP.plotPolarGrid(varargin{:});

        set(ax,'box','on','XTick',[],'YTick',[]);
        axis(ax,'off');
    
        % compute bounding box
        x = ensurecell(get(sP.boundary,'xData')); x = [x{:}];
        y = ensurecell(get(sP.boundary,'yData')); y = [y{:}];
        bounds = [min(y(:)),min(x(:)),max(y(:)),max(x(:))];
        if ~check_option(varargin,'grid')
          set(sP.grid,'visible','off');
        end
        
      end
      
      plotAnnotate(sP,varargin{:});
      
      % revert old hold status
      hold(ax,washold);
      
      % set bounds to axes
      delta = min(bounds(3:4) - bounds(1:2))*0.02;

      set(ax,'DataAspectRatio',[1 1 1],...
        'XLim',[bounds(2)-delta,bounds(4)+delta],...
        'YLim',[bounds(1)-delta,bounds(3)+delta]);
      
      % set view point
      setCamera(ax);
      
    end

    function plotAnnotate(sP,varargin)
      % tl tr bl br
    
      t.TL = get_option(varargin,{'TopLeft','TL'},'');
      t.TR = get_option(varargin,{'TopRight','TR'},'');
      t.BL = get_option(varargin,{'BottomLeft','BL'},'');
      t.BR = get_option(varargin,{'BottomRight','BR'},'');
      
      t = structfun(@(x) st2char(x), t,'UniformOutput',false);

      m = 0.005;
      if strcmpi(getMTEXpref('textInterpreter'),'LaTex')
        b = 0.015;
      else
        b = 0;
      end

      if isempty(sP.TL)
        options = {'parent',sP.ax,'units','normalized',...
          'FontName','times','FontSize',13,...
          'interpreter',getMTEXpref('textInterpreter','latex')};
        sP.TL = text(0+m,1-b,t.TL,options{:});
        sP.TR = text(1-m,1-b,t.TR,options{:});
        sP.BL = text(0+m,0+b,t.BL,options{:});
        sP.BR = text(1-m,0+b,t.BR,options{:});
        
        set([sP.TL sP.TR],'VerticalAlignment','top');
        set([sP.BL sP.BR],'VerticalAlignment','bottom');
        set([sP.TL sP.BL],'HorizontalAlignment','left');
        set([sP.TR sP.BR],'HorizontalAlignment','right');

      else
        if ~isempty(t.TL), set(sP.TL,'String',t.TL); end
        if ~isempty(t.BL), set(sP.BL,'String',t.BL); end
        if ~isempty(t.TR), set(sP.TR,'String',t.TR); end
        if ~isempty(t.BR), set(sP.BR,'String',t.BR); end        
      end
      

      function s = st2char(t)

        if isa(t,'cell') && numel(t) == 1, t = t{1};end
        if isa(t,'vector3d')
          for i = 1:length(t)

            s{i} = char(t(i),getMTEXpref('textInterpreter')); %#ok<AGROW>

          end
        else
          if iscell(t)
            s = t;
          elseif ~ischar(t)
            s = char(t);
          else
            s = t;
          end
          if strcmpi(getMTEXpref('textInterpreter'),'LaTex')
            if ~iscell(s) && ~isempty(regexp(s,'[\\\^_]','ONCE')) && s(1)~='$'
              s = ['$' s '$'];
            end
          end
        end
      end
    end
    
    function sR = get.sphericalRegion(sP)
      sR = sP.proj.sR;
    end   
    
    function doGridInFront(sP)
      
      if ~isempty(sP.grid)
        childs = allchild(sP.ax);
  
        isgrid = ismember(childs,[sP.grid,sP.boundary]);
        istext = strcmp(get(childs,'type'),'text');
  
        % TODO: this crahes on MATLAB 2014b
        set(sP.ax,'Children',[childs(istext); sP.boundary(:); sP.grid(:);childs(~isgrid & ~istext)]);
      end
    end    
  end
  
  methods (Access = private)
  
    function plotPlainGrid(sP,varargin)
      
      % the ticks
      %dgrid = get_option(varargin,'grid_res',30*degree);
      polarRange = sP.sphericalRegion.polarRange;
      theta = round(linspace(polarRange(1),polarRange(3),4)/degree);
      rho = round(linspace(polarRange(2),polarRange(4),4)/degree);      
      %theta = round((polarRange(1):dgrid:polarRange(3))/degree);
      %rho = round((polarRange(2):dgrid:polarRange(4))/degree);
      
      set(sP.ax,'XTick',rho);
      set(sP.ax,'YTick',theta);

      % the labels
      interpreter = getMTEXpref('textInterpreter');
      xlabel(sP.ax,get_option(varargin,'xlabel','rho'),...
        'interpreter',interpreter,'FontSize',12,'VerticalAlignment','bottom');
      ylabel(sP.ax,get_option(varargin,'ylabel','theta'),...
        'interpreter',interpreter,'FontSize',12,'VerticalAlignment','top');
      
    end

    function plotPolarGrid(sP,varargin)
      
      % stepsize
      dgrid = get_option(varargin,'grid_res',30*degree);
      dgrid = pi/round((pi)/dgrid);
      
      % draw small circles
      theta = dgrid:dgrid:pi/2-dgrid;
      if sP.sphericalRegion.isLower, theta = pi-theta;end
      for i = 1:length(theta), circ(sP,theta(i)); end
      
      % draw meridians
      rho = 0:dgrid:2*pi-dgrid;
      for i = 1:length(rho), plotMeridian(sP,rho(i)); end

    end

    
    function plotMeridian(sP,rho,varargin)

      % the points
      if sP.sphericalRegion.isUpper
        v = sph2vec(linspace(0,pi/2,181),rho);
      else
        v = sph2vec(linspace(pi,pi/2,181),rho);
      end
      
      [x,y] = project(sP.proj,v);
      ind = ~isnan(x);
      i1 = find(ind,1,'first');
      i2 = find(ind,1,'last');
      x = x([i1,i2]);
      y = y([i1,i2]);

      % grid
      sP.grid(end+1) = line(x,y,'parent',sP.ax,...
        'handlevisibility','off','color',[.8 .8 .8]);

      s = [xnum2str(rho/degree) mtexdegchar];
      sP.ticks(end+1) = text(x(end),y(end),s,'parent',sP.ax,...
        'interpreter','tex','handlevisibility','off',...
        'FontName','Ubuntu','fontsize',8,'visible','off');

      return

      % vertical/horizontal alignment
      va = {'middle','bottom','middle','top'};
      ha = {'left','center','right','center'};
      r = mod(round(atan2(Y(1,:),X(1,:))/pi*2),4)+1;

      options = [{'HorizontalAlignment',ha{r},'VerticalAlignment',va{r}},varargin];
      
    end
    
    function circ(sP,theta,varargin)

      % the points to plot      
      v = vector3d('theta',theta,'rho',linspace(0,2*pi,721));
      
      % project
      [dx,dy] = sP.proj.project(v);

      % plot
      sP.grid(end+1) = line(dx,dy,'parent',sP.ax,...
        'handlevisibility','off','color',[.8 .8 .8]);

    end
    
  end
end

% 
% 
% % control legend entry
% try
%   hAnnotation = get(l,'Annotation');
%   hLegendEntry = get([hAnnotation{:}],'LegendInformation');
%   set([hLegendEntry{:}],'IconDisplayStyle','off')
% catch %#ok<CTCH>
% end
% 
% % labels
% 
% 
% if any(isnan(X)), return;end
% if check_option(varargin,'ticks'), v = 'on';else v = 'off';end
% 
% % set back color index
% if isappdata(gca,'PlotColorIndex')
%   if isempty(colorIndex)
%     setappdata(gca,'PlotColorIndex',1);
%   else
%     setappdata(gca,'PlotColorIndex',colorIndex);
%   end
% end
% 
% end
