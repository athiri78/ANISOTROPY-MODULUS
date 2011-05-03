function handles = import_gui_data(wzrd,varargin)
% page for adding files to be imported

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);
ph = 270;

this_page = get_panel(w,h,ph);

handles = getappdata(wzrd,'handles');
handles.pages = [handles.pages,this_page];
setappdata(this_page,'pagename','Select Data Files');

set(this_page,'visible','off');

if check_option(varargin,'EBSD')
  select = 2;
elseif check_option(varargin,'ODF')
  select = 3;
elseif check_option(varargin,'tensor')
  select = 4;
else
  select = 1;
end

handles.tabs = uitabpanel(...
  'Parent',this_page,...
  'TabPosition','lefttop',...
  'units','pixel',...
  'position',[0,0,w-18,260],...
  'Margins',{[2,2,2,2],'pixels'},...
  'PanelBorderType','beveledout',...
  'Title',{'Pole Figures','EBSD','ODF','Tensor'},... %,'Background','Defocussing','Defocussing BG'},...
  'FrameBackgroundColor',get(gcf,'color'),...
  'PanelBackgroundColor',get(gcf,'color'),...
  'TitleForegroundColor',[0,0,0],...
  'selectedItem',select);

panels = getappdata(handles.tabs,'panels');

if select == 1 || ~check_mtex_option('generate_help')
  handles.tabs_pf = uitabpanel(...
    'Parent',panels(1),...
    'Style','popup',...
    'TabPosition','lefttop',...
    'units','pixel',...
    'position',[2,2,w-155,230],...
    'Margins',{[0,0,-10,0],'pixels'},...
    'PanelBorderType','beveledout',...
    'Title',{'Data','Background','Defocussing','Defocussing BG'},...
    'FrameBackgroundColor',get(gcf,'color'),...
    'PanelBackgroundColor',get(gcf,'color'),...
    'TitleForegroundColor',[0,0,0],...
    'selectedItem',1);
  
  handles.datapane = [getappdata(handles.tabs_pf,'panels') panels(2:end)];
  
else

  handles.datapane = panels(1:end);
  
end

handles.importcpr = uicontrol(...
  'Parent',panels(2),...
  'String','Import Project-Settings',...
  'TooltipString','imports phase information from a project file (*.cpr)',...
  'CallBack',{@importProjectSettings},...
  'Position',[w-145 ph-150 115 25]);


handles.add = uicontrol(...
  'Parent',this_page,...
  'cdata',icon('add'),...
  'TooltipString','add data file',...
  'Callback',{@addData},...
  'Position',[w-145 ph-80 25 25]);
  
handles.del = uicontrol(...
  'Parent',this_page,...
  'cdata',icon('delete'),...
  'TooltipString','remove data file',...
  'CallBack',{@delData},...
  'Position',[w-145 ph-110 25 25]);


handles.up = uicontrol(...
  'Parent',this_page,...
  'style','pushbutton',...
  'cdata',icon('up'),...
  'TooltipString','move data file upwards',...
  'CallBack',{@shiftData,+1},...
  'Position',[w-145 ph-220 25 25]);

handles.down = uicontrol(... 
  'cdata',icon('down'),...
  'TooltipString','move data file downwards',...
  'style','pushbutton',...
  'Parent',this_page,...
  'CallBack',{@shiftData,-1},...
  'Position',[w-145 ph-250 25 25]);


paneltypes = {'PoleFigure','PoleFigure','PoleFigure','PoleFigure','EBSD','ODF','Tensor'};

for k = 1:length(handles.datapane)  
  handles.listbox(k) = uicontrol(...
    'Parent',handles.datapane(k),...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Max',2,...
    'Position',[9 10 w-165 ph-75],...
    'String',blanks(0),...
    'Style','listbox',...
    'tag',paneltypes{k},...
    'Value',1);
end

if select == 1 || ~check_mtex_option('generate_help')
  for k=5:6
    set(handles.listbox(k),'Position',[9 10 w-165 ph-65])
  end
end

handles.interface = uicontrol(...
  'Parent',this_page,...
  'HitTest','off',...
  'Style','text',...
  'units','pixel',...
  'position',[w-190,ph-30,180,13],...
  'string','');


setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% ------------- Callbacks -----------------------------------------

function goto_callback(varargin)

data = getappdata(gcbf,'data');
handles = getappdata(gcbf,'handles');

if ~isempty(getappdata(handles.listbox(1),'data'))
  
  % for pole figures take care not to change the data  
  pf = getappdata(handles.listbox(1),'data');
  d = get(pf,'intensities');
  data = set(data,'intensities',d);
  setappdata(handles.listbox(1),'data',data);

elseif ~isempty(getappdata(handles.listbox(5),'data'))
  
  ebsd = getappdata(handles.listbox(5),'data');
  setappdata(gcbf,'data',ebsd);
  
elseif ~isempty(getappdata(handles.listbox(6),'data'))
  setappdata(handles.listbox(6),'data',data); 
else
  setappdata(handles.listbox(7),'data',data);
end

function leave_callback(varargin)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;

pf = getappdata(lb(1),'data');
ebsd = getappdata(lb(5),'data');
odf = getappdata(lb(6),'data');
tensor = getappdata(lb(7),'data');

s = ~isempty(pf) + ~isempty(ebsd) + ~isempty(odf) + ~isempty(tensor);
if s == 0
  error('Add some data files to be imported!');
elseif s > 1
  error('You can only import one type of data! Clear one list to proceed!');
end

if ~isempty(ebsd)
  
  filename = getappdata(lb(5),'filename');
  setappdata(gcbf,'data',ebsd);  
  setappdata(lb(5),'zvalues',[]);
  if numel(filename) > 1,
    choice = questdlg({'More than one EBSD data set imported.',' Do you want to treat it as 3d data?'},'EBSD 3d');
    switch choice 
      case 'Yes'
        setappdata(lb(5),'zvalues',1:numel(filename));        
    end
  end
  
  handles.pages = handles.ebsd_pages;
  
  vname = 'ebsd';
elseif ~isempty(odf)
  
  setappdata(gcbf,'data',odf);
  handles.pages = handles.odf_pages;
  
  vname = 'odf';
elseif ~isempty(pf) 
  
  % pole figure correction
  bg = getappdata(lb(2),'data');
  def = getappdata(lb(3),'data');
  def_bg = getappdata(lb(4),'data');
  pf = correct(pf,'bg',bg,'def',def,'defbg',def_bg);

  setappdata(gcbf,'data',pf);
  handles.pages = handles.pf_pages;
  
  vname = 'pf';
elseif ~isempty(tensor)
  
  setappdata(gcbf,'data',tensor);
  handles.pages = handles.tensor_pages;
  
  vname = 'tensor';
end

set(handles.workspace(1),'String',vname);
setappdata(gcbf,'handles',handles);


function addData(h,event,t) %#ok<INUSL>

handles = getappdata(gcbf,'handles');
pane = handles.datapane;
t= find(strcmpi(get(pane,'visible'),'on'),1,'last');
addfile(handles.listbox(t(end)),get(handles.listbox(t(end)),'tag'));


function delData(h,event)  %#ok<INUSL>

handles = getappdata(gcbf,'handles');
pane = handles.datapane;
t= find(strcmpi(get(pane,'visible'),'on'),1,'last');
delfile(handles.listbox(t(end)));


function shiftData(h,event,drc)

handles = getappdata(gcbf,'handles');
pane = handles.datapane;
t= find(strcmpi(get(pane,'visible'),'on'),1,'last');
lb = handles.listbox(t(end));

data = getappdata(lb,'data');
idata = getappdata(lb,'idata');
filename = getappdata(lb,'filename');

if ~isempty(data)
  pos = get(lb,'Value');
  pp = 1:numel(filename);
    
  if pos(1) > 1 && drc > 0 % up
    for k=pos
      tpp = pp;
      pp(k-1) = pp(k);
      pp(k) = tpp(k-1);
    end
  elseif pos(end) < numel(filename) && drc < 0 % down
    for k=pos(end:-1:1)
      tpp = pp;
      pp(k) = pp(k+1);
      pp(k+1) = tpp(k);
    end
  else
    return
  end
    
  csz = cumsum(idata);
  sp = cell(numel(data),1);
  for k=1:numel(idata)-1;
    sp{k} = csz(k)+1:csz(k+1);
  end
  sp = [sp{pp}];
 
  setappdata(lb,'data',data(sp));
  tidata = idata(2:end);
  idata(2:end) = tidata(pp);
  setappdata(lb,'idata',idata);
  setappdata(lb,'filename',filename(pp));
  
  str = get(lb,'String');
  set(lb,'String',str(pp));
  set(lb,'Value',pos-drc);
 
end


function importProjectSettings(h,event)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;
ebsd = getappdata(lb(5),'data');


if ~isempty(ebsd) 
  try
    [file path] = uigetfile('*.cpr','Select associated CPR Project-file');
    if file ~=0
      phases = cprproject_read(fullfile(path,file));
      ebsd = set(ebsd,'CS',phases(get(ebsd,'phase')),'noTrafo');  
      setappdata(lb(5),'data',ebsd);
      msgbox('Phases information successfully loaded!')
    end
  catch
    errordlg('failed to import Project file')
  end
end


%%
function cdata = icon(type)

switch type
  case 'add'
    cdata = [ ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
      NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      ];
  case 'delete'
    cdata = [ ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
      NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      ];
  case 'up'
    cdata = [ ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN   0   0   0   0 NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN   0   0   0   0   0   0 NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN   0   0   0   0   0   0   0   0 NaN NaN NaN NaN ; ...
      NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
      NaN NaN   0   0   0   0   0   0   0   0   0   0   0   0 NaN NaN ; ...
      NaN   0   0   0   0   0   0   0   0   0   0   0   0   0   0 NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      ];
  case 'down'
    cdata = [ ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN   0   0   0   0   0   0   0   0   0   0   0   0   0   0 NaN ; ...
      NaN NaN   0   0   0   0   0   0   0   0   0   0   0   0 NaN NaN ; ...
      NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
      NaN NaN NaN NaN   0   0   0   0   0   0   0   0 NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN   0   0   0   0   0   0 NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN   0   0   0   0 NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
      ];
end

cdata = repmat(cdata,[1,1,3]);
