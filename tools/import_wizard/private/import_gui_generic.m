function import_gui_generic(wzrd)
% generic import wizard page

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);

handles = getappdata(wzrd,'handles');
handles.pages = [];

%% page title
handles.name = uicontrol(...
'Parent',wzrd,...
 'FontSize',12,...
 'ForegroundColor',[0.3 0.3 0.3],...
 'FontWeight','bold',...
 'BackgroundColor',[1 1 1],...
 'HorizontalAlignment','left',...
 'Position',[10 h-37 w-150 20],...
 'Style','text',...
 'HandleVisibility','off',...
 'HitTest','off');

%% navigation
handles.next = uicontrol(...
  'Parent',wzrd,...
  'String','Next >>',...
  'CallBack',@next_callback,...
  'Position',[w-30-80*2 10 80 25]);

handles.prev = uicontrol(...
  'Parent',wzrd,...
  'String','<< Previous',...
  'CallBack',@prev_callback,...
  'Position',[w-30-80*3 10 80 25]);

handles.finish = uicontrol(...
  'Parent',wzrd,...
  'String','Finish',...
  'Enable','off',...
  'CallBack',@finish_callback,...
  'Position',[w-90 10 80 25]);

handles.plot = uicontrol(...
  'Parent',wzrd,...
  'String','Plot',...
  'CallBack',@plot_callback,...
  'Position',[10 10 80 25],...
  'Visible','on');

uipanel(...
  'units','pixel',...
  'HighlightColor',[0 0 0],...
  'Position',[10 50 w-20 1]);

handles.proceed = [handles.next handles.prev handles.finish,handles.plot];
setappdata(wzrd,'handles',handles);


%% ----------------- Callbacks ----------------------------------

function next_callback(varargin)

switch_page(gcbf,+1);


function prev_callback(varargin)
  
switch_page(gcbf,-1);


function plot_callback(varargin)

page = getappdata(gcbf,'page');
handles = getappdata(gcbf,'handles');

if page == 1
  
  tab = getappdata(handles.tabs,'value');
  data = getappdata(handles.listbox(tab),'data');
  if isempty(data)
    errordlg('Nothing to plot! Add files to import first!');
    return;    
  end
else
  leavecallback = getappdata(handles.pages(page),'leave_callback');
  try
    leavecallback();
  catch
    errordlg(errortext);
    return
  end
    
  data = getappdata(gcbf,'data');
  
end

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/8 scrsz(4)/8 6*scrsz(3)/8 6*scrsz(4)/8]);

if isa(data,'EBSD')
  plot_EBSD(gcbf,data);
else
  plot_pf(gcbf,data);
end


function finish_callback(varargin)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;

data = getappdata(gcbf,'data');

if isa(data,'EBSD')  
  vname = 'ebsd';  
else    
  data = modifypf(gcbf,data);
  vname = 'pf';  
end

%% copy to workspace
if ~get(handles.runmfile,'Value');

  a = inputdlg({'Enter name of workspace variable'},'MTEX Import Wizard',1,{vname});
  assignin('base',a{1},data);
  if isempty(javachk('desktop')) 
    if isa(data,'EBSD')
      disp(['Imported EBSD Data: ', a{1}]);
      disp(['- <a href="matlab:plot(',a{1},',''silent'')">Plot EBSD Data</a>']);
      disp(['- <a href="matlab:calcODF(',a{1},')">Calculate ODF</a>']);
      disp(' ');
    else
      disp(['imported Pole Figure Data: ', a{1}]);
      disp(['- <a href="matlab:plot(',a{1},',''silent'')">Plot Pole Figure Data</a>']);
      disp(['- <a href="matlab:calcODF(',a{1},')">Calculate ODF</a>']);
      disp(' ');
    end
  end
  
%% write to file
else 
    
  % extract file names
  for i = 1:length(lb)
    fn{i} = getappdata(lb(i),'filename');
  end
  
  if ~isempty(fn{2}) % EBSD data
    str = exportEBSD(fn{2},data,getappdata(lb(2),'interface'), getappdata(lb(2),'options'));
  else
    fn(2) = [];
    if all(cellfun('isempty',fn(2:end)))
      fn = fn{1};
    end
    str = exportPF(fn,data,getappdata(lb(1),'interface'), getappdata(lb(1),'options'));
  end
       
  str = generateCodeString(str);
  openuntitled(str);
end

close


%% ------------ Private Functions ----------------------------------

function switch_page(wzrd,delta)
% switch between pages

page = getappdata(wzrd,'page');
handles = getappdata(wzrd,'handles');
leavecallback = getappdata(handles.pages(page),'leave_callback');
try
  leavecallback();
  page = page + delta;
  gotocallback = getappdata(handles.pages(page),'goto_callback');
  gotocallback();
  set_page(wzrd,page);
catch 
  errordlg(errortext);
end


function str = generateCodeString(strCells)

str = [];
for n = 1:length(strCells)
    str = [str, strCells{n}, sprintf('\n')];
end


function plot_EBSD(wzrd,ebsd)  %#ok<INUSL>

plot(ebsd);


function plot_pf(wzrd,pf)

pf = modifypf(wzrd,pf);
plot(pf,'silent');
plot2all([xvector,yvector,zvector],'Backgroundcolor','w','bulletcolor','k');


function pf = modifypf(wzrd,pf)
% Modify ODF before exporting or plotting

handles = getappdata(wzrd,'handles');
if get(handles.rotate,'value')
  pf = rotate(pf,str2num(get(handles.rotateAngle,'string'))*degree);
end

%if get(handles.dnv,'value')
%  pf = delete(pf,getdata(pf)<0);
%end

%if get(handles.setnv,'value')
%  pf = setdata(pf,str2num(get(handles.rnv,'string')),getdata(pf)<0);
%end

