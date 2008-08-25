function handles = import_gui_ss( handles )

pos = get(handles.wzrd,'Position');
h = pos(4);
w = pos(3);

ph = 270;

%% page 4
hp = get_panel(w,h,ph);
handles.pages = [handles.pages,hp];
set(hp,'visible','off');


scs = uibuttongroup('title','Specimen Coordinate System',...
  'Parent',hp,...
  'Visible','off',...
  'units','pixels','position',[0 ph-150 380 140]);

uicontrol(...
 'Parent',scs,...
  'String','Symmetry',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'Position',[10 90  100 15]);

handles.specime = uicontrol(...
  'Parent',scs,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[100 90 260 20],...
  'String',blanks(0),...
  'Style','popup',...
  'String',symmetries,...
  'Visible','off',...
  'Value',1);


handles.rotate = uicontrol(...
  'Parent',scs,...
  'Style','check',...
  'String','rotate around z-axis by ',...
  'Value',0,...
  'Visible','off',...
  'position',[10 40 180 20]);

handles.rotateAngle = uicontrol(...
  'Parent',scs,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[190 38 80 25],...
  'String','0',...
  'Visible','off',...
  'Style','edit');

uicontrol(...
  'Parent',scs,...
  'String','degree',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'Position',[280 35 50 20]);

handles.flipud = uicontrol(...
  'Parent',scs,...
  'Style','check',...
  'String','flip upside down',...
  'Value',0,...
  'Visible','off',...
  'position',[10 10 160 20]);

handles.fliplr = uicontrol(...
  'Parent',scs,...
  'Style','check',...
  'String','flip left to right',...
  'Value',0,...
  'Visible','off',...
  'position',[190 10 120 20]);

uicontrol(...
  'String',['Use the plot command', ...
   'to verify that the specimen coordinate' ...
   ' system is aligned properly to the data!'],...
  'Parent',hp,...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'Position',[5 0 390 30]);


% nv = uibuttongroup('title','Negative Values',...
%   'Parent',hp,...
%   'Visible','off',...
%   'units','pixels','position',[0 ph-210 380 100]);
% 
% uicontrol(...
%   'Parent',nv,...
%   'Style','radi',...
%   'String','keep negative values',...
%   'Value',1,...
%   'Visible','off',...
%   'position',[10 60 160 20]);
% 
% handles.dnv = uicontrol(...
%   'Parent',nv,...
%   'Style','radi',...
%   'String','delete negative values',...
%   'Value',0,...
%   'Visible','off',...
%   'position',[10 35 160 20]);
% 
% handles.setnv = uicontrol(...
%   'Parent',nv,...
%   'Style','radi',...
%   'String','set negative values to',...
%   'Value',0,...
%   'Visible','off',...
%   'position',[10 10 160 20]);
% 
% handles.rnv = uicontrol(...
%   'Parent',nv,...
%   'BackgroundColor',[1 1 1],...
%   'FontName','monospaced',...
%   'HorizontalAlignment','right',...
%   'Position',[190 8 80 25],...
%   'String','0',...
%   'Visible','off',...
%   'Style','edit');
% 
% 
% co = uibuttongroup('title','Comment',...
%   'Parent',hp,...
%   'Visible','off',...
%   'units','pixels','position',[0 0 380 54]);
% 
% handles.comment = uicontrol(...
%   'Parent',co,...
%   'BackgroundColor',[1 1 1],...
%   'FontName','monospaced',...
%   'HorizontalAlignment','left',...
%   'Position',[10 8 360 25],...
%   'String',blanks(0),...
%   'Visible','off',...
%   'Style','edit');
