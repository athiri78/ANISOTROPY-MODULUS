function handles = import_gui_miller( handles )

pos = get(handles.wzrd,'Position');
h = pos(4);
w = pos(3);

ph = 270;


%% hkil page
this_page = get_panel(w,h,ph);
handles.pages = [handles.pages,this_page];
set(this_page,'visible','off');

uicontrol(...
  'String','Imported Pole Figure Data Sets',...
  'Parent',this_page,...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'Position',[10 ph-25 200 15]);

handles.listbox_miller = uicontrol(...
'Parent',this_page,...
'BackgroundColor',[1 1 1],...
'FontName','monospaced',...
'HorizontalAlignment','left',...
'Max',2,...
'Position',[15 37 225 ph-70],...
'String',blanks(0),...
'Style','listbox',...
'Max',1,...
'Callback','import_wizard_PoleFigure(''update_miller'')',...
'Visible','off',...
'Value',1);

mi = uibuttongroup('title','Miller Indece',...
  'Parent',this_page,...
  'Visible','off',...
  'units','pixels','position',[260 ph-160 120 150]);

ind = {'h','k','i','l'};
for k=1:4
uicontrol(...
 'Parent',mi,...
  'String',ind{k},...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','right',...
  'Visible','off',...
  'Position',[10 132-30*k 10 15]);
handles.miller{k} = uicontrol(...
  'Parent',mi,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[30 130-30*k 70 22],...
  'String',blanks(0),...
  'Callback','import_wizard_PoleFigure(''update_indices'')',...
  'Visible','off',...
  'Style','edit');
end

sc = uibuttongroup('title','Structure Coeff.',...
  'Parent',this_page,...
  'Visible','off',...
  'units','pixels','position',[260 ph-230 120 55]);

uicontrol(...
 'Parent',sc,...
  'String','c',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','right',...
  'Visible','off',...
  'Position',[10 10 10 15]);

handles.structur = uicontrol(...
  'Parent',sc,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[30 10 70 22],...
  'String',blanks(0),...
  'Callback','import_wizard_PoleFigure(''update_indices'')',...
  'Visible','off',...
  'Style','edit');

uicontrol(...
  'String',['For superposed pole figures seperate multiple Miller indece ', ...
  'and structure coefficients by space!'],...
  'Parent',this_page,...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'Position',[5 0 390 30]);
