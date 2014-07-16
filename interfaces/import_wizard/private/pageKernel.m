function pageKernel(api)
% page for setting specimen symmetry

getODF = api.Export.getOptODF;
setODF = api.Export.setOptODF;

gui = localCreatePage();

api.setWizardTitle('ODF Interpolation Method')
api.setWizardDescription('Set Smoothing Kernel')

api.setLeavePageCallback(@leavePage);
api.setGotoPageCallback(@gotoPage);


set(gui.hKernelGroup ,'SelectionChangeFcn',@localChange)
set(gui.hKernel      ,'Callback',@localChange)
set(gui.hHalfwidth   ,'Callback',@localChange)
set(gui.hExact       ,'Callback',@localChange)
set(gui.hApprox      ,'Callback',@localChange)


  function nextPage = leavePage
    
    nextPage = @pageFinish;
    
  end

  function gotoPage
    
    api.Progress.enableNext(true);
    
    localUpdateGUI();
    
  end

  function localChange(source,event)
    
    kname = get(gui.hKernel,'String');
    kname = kname{get(gui.hKernel,'Value')};
    
    hw    = str2num(get(gui.hHalfwidth,'String'))*degree;
    psi   = kernel(kname,'halfwidth',hw);
    
    data  = cellfun(@(x)set(x,'psi',psi),api.getData(),'Uniformoutput',false);
    api.setData(data);
    
    setODF('method',get(gui.hMethod(2),'Value'));
    setODF('exact',get(gui.hExact,'Value'));
    setODF('approx',get(gui.hApprox,'String'));
    
    localUpdateGUI();
    
  end


  function localUpdateGUI()
    
    data = api.getData();
    data = [data{:}];
    
    psi = data.psi;
    
    kname = psi.name;
    hw    = psi.halfwidth;
    
    set(gui.hKernel,'Value',...
      find(strcmp(get(gui.hKernel,'String'),kname)));
    
    set(gui.hHalfwidth,'String',xnum2str(hw/degree));
    
    set(gui.hMethod(1),'Value',~getODF('method'));
    set(gui.hMethod(2),'Value',getODF('method'));
    
    set(gui.hExact,'Value',getODF('exact'));
    
    state = {'off','on'};
    set(gui.hApprox,'Enable',state{1+getODF('exact')});
    set(gui.hApprox,'String',getODF('approx'));
    
    plotKernel(psi,data.CS);
    
  end

  function plotKernel(k,CS)
    
    try
      ma = 2* pi / CS.multiplicityZ;
      omega = linspace(-ma/2,ma/2,5000);
      
      v = eval(k,omega); %#ok<EVLC>
      plot(gui.hKernelAxis,omega/degree,v,'linewidth',2);
      set(gui.hKernelAxis,'ylim',[min([0,v]),max(v)],'yTick',[]);
      set(gui.hKernelAxis,'xlim',[min(omega)/degree,max(omega)/degree]);
    catch %#ok<CTCH>
    end
  end

  function gui = localCreatePage()
    
    page = api.hPanel;
    
    h    = api.Spacings.PageHeight;
    w    = api.Spacings.PageWidth;
    m    = api.Spacings.Margin;
    bH   = api.Spacings.ButtonHeight;
    fs   = api.Spacings.FontSize;
    
    
    kg = uibuttongroup('title','Smoothing Kernel',...
      'Parent',page,...
      'FontSize',fs,...
      'units','pixels','position',[1 0 w h]);
    
    % ODF approximation
    method(1) = uicontrol(...
      'Parent',kg,...
      'Style','radio',...
      'FontSize',fs,...
      'String','ODF is given by function values at grid points',...
      'Value',0,...
      'position',[m m+bH/3*2 w-2*m bH/3*2]);
    
    method(2) = uicontrol(...
      'Parent',kg,...
      'Style','radio',...
      'FontSize',fs,...
      'String','ODF is given by accordingly distributed orientations ',...
      'Value',0,...
      'position',[m m w-2*m bH/2]);
    
    % kernel smoothing    
    left = @(offset,height) [m h-2*m-offset w/2-2*m height];
    
    uicontrol(...
      'Parent',kg,...
      'String','Kernel type',...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',left(bH,bH*2/3));
    
    
    knames = kernel('names');
    rm = cellfun(@(s) strmatch(s,knames),{'Laplace','Fourier','user'});
    knames(rm) = [];
    
    kern = uicontrol(...
      'Parent',kg,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',left(2*bH,bH),...
      'String',blanks(0),...
      'Style','popup',...
      'String',knames,...
      'Value',1);
    
    uicontrol(...
      'Parent',kg,...
      'String','Halfwidth',...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',left(3*bH+10,bH));
    
    halfwidth = uicontrol(...
      'Parent',kg,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'FontSize',fs,...
      'HorizontalAlignment','right',...
      'Position',left(3*bH,25)+[ 100 0 -100 0],...
      'String','5',...
      'Style','edit');
    
    exact = uicontrol(...
      'Parent',kg,...
      'Style','check',...
      'FontSize',fs,...
      'String','use binning',...
      'Value',1,...
      'position',left(4.5*bH,bH));
    
    
    uicontrol(...
      'Parent',kg,...
      'Style','text',...
      'FontSize',fs,...
      'String','binning width',...
      'HitTest','off',...
      'HorizontalAlignment','left',...
      'position',left(5.5*bH+10,bH));
    
    approx = uicontrol(...
      'Parent',kg,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'FontSize',fs,...
      'HorizontalAlignment','right',...
      'Position',left(5.5*bH,25)+[100 0 -100 0],...
      'String','5',...
      'Style','edit'); 
        
    % kernel plot    
    kernelAxis = axes(...
      'Parent',kg,...
      'Units','pixels',...
      'FontSize',fs,...
      'Position',[w/2+m m+65 w/2-2*m h-65-3*m],...
      'yTick',[],...
      'box','on');
    
    gui.hKernelGroup  = kg;
    gui.hKernel       = kern;
    gui.hMethod       = method;
    gui.hApprox       = approx;
    gui.hExact        = exact;
    
    gui.hHalfwidth    = halfwidth;
    gui.hKernelAxis   = kernelAxis;
    
  end

end
