function [odf,options] = loadODF_generic(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
%% Description 
%
% *loadEBSD_txt* is a generic function that reads any txt or exel files of
% diffraction intensities that are of the following format
%
%  alpha_1 beta_1 gamma_1 weight_1
%  alpha_2 beta_2 gamma_2 weight_2
%  alpha_3 beta_3 gamma_3 weight_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  alpha_M beta_M gamma_M weight_m
%
% The assoziation of the columns as Euler angles, phase informationl, etc.
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
%% Syntax
%  odf   = loadODF_generic(fname,<options>)
%
%% Input
%  fname - file name (text files only)
%
%% Options
%  ColumnNames  - names of the colums to be imported, mandatory are euler 1, euler 2, euler 3 
%  Columns      - postions of the columns to be imported
%  RADIANS      - treat input in radiand
%  DELIMITER    - delimiter between numbers
%  HEADER       - number of header lines
%  ZXZ, BUNGE   - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  ZYZ, ABG     - [alpha beta gamma] Euler angle in Mathies convention
%
% 
%% Example
%
%    fname = fullfile(mtexDataPath,'odf','odf.txt');
%    odf = loadODF_generic(fname,'cs',symmetry('cubic'),'header',5,...
%      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'weight'},...
%      'Columns',[1,2,3,4])
%
%% See also
% import_wizard loadODF ODF_demo

odf = ODF;

% get options
ischeck = check_option(varargin,'check');
cs = get_option(varargin,'cs',symmetry('m-3m'));
ss = get_option(varargin,'ss',symmetry('-1'));

% load data
[d,varargin,header,c] = load_generic(char(fname),varargin{:});

% no data found
if size(d,1) < 1 || size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% no options given -> ask
if ~check_option(varargin,'ColumnNames')
  
  options = generic_wizard('data',d(1:end<101,:),'type','ODF','header',header,'columns',c);
  if isempty(options), odf = []; return; end
  varargin = [options,varargin];

end

names = lower(get_option(varargin,'ColumnNames'));
cols = get_option(varargin,'Columns',1:length(names));

assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

[names m] = unique(names);
cols = cols(m);

istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(in,x))),a));
layoutcol = @(in, a) cols(cellfun(@(x) find(strcmpi(in,x)),a));
   
euler = lower({'Euler 1' 'Euler 2' 'Euler 3' 'weight'});
quat = lower({'Quat real' 'Quat i' 'Quat j' 'Quat k' 'weight'});
      
if istype(names,euler) % Euler angles specified
    
  layout = layoutcol(names,euler);
    
  %extract options
  dg = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});
    
  % eliminate nans
  d(any(isnan(d(:,layout)),2),:) = [];
  
  % eliminate rows where angle is 4*pi
  ind = abs(d(:,layout(1))*dg-4*pi)<1e-3;
  d(ind,:) = [];
    
  % extract data
  alpha = d(:,layout(1))*dg;
  beta  = d(:,layout(2))*dg;
  gamma = d(:,layout(3))*dg;
  weight = d(:,layout(4));

  assert(all(beta >=-1e-3 & beta <= pi+1e-3 & alpha >= -2*pi-1e-3 &...
    alpha <= 4*pi+1e-3 & gamma > -2*pi-1e-3 & gamma<4*pi+1e-3));
  
  % check for choosing
  if ~ischeck && max(alpha) < 10*degree
    warndlg('The imported Euler angles appears to be quit small, maybe your data are in radians and not in degree as you specified?');
  end
    
  % transform to quaternions
  q = euler2quat(alpha,beta,gamma,varargin{:});
  
elseif istype(names,quat) % import quaternion
    
  layout = layoutcol(names,quat);
  d(any(isnan(d(:,layout)),2),:) = [];
  q = quaternion(d(:,layout(1)),d(:,layout(2)),d(:,layout(3)),d(:,layout(4)));
  weight = d(:,layout(4));
  
else
  error('You should at least specify three Euler angles or four quaternion components and the corresponding weight!');
end
   
if check_option(varargin,'passive rotation'), q = inverse(q); end
 
% return varargin as options
options = varargin;
if ischeck, odf = uniformODF(symmetry,symmetry);return;end

if numel(unique(weight)) > 1
  defaultMethod = 'interp';
else
  defaultMethod = 'density';
end

method = get_flag(varargin,{'interp','density'},defaultMethod);

switch method
  
  case 'density'

    % load single orientations
    if ~check_option(varargin,{'exact','resolution'}), varargin = [varargin,'exact'];end
    ebsd = EBSD(q,cs,ss,varargin{:});
    
    % calc ODF
    odf = calcODF(ebsd,'weight',weight,'silent',varargin{:});    
    
  case 'interp'
  
    disp('  Interpolating the ODF. This might take some time...')
    res = get_option(varargin,'resolution',3*degree);
  
    % interpolate
    S3G = SO3Grid(res,cs,ss);

    % get kernel
    psi = get_option(varargin,'kernel',kernel('de la Vallee Poussin','halfwidth',res));

    M = K(psi,S3G,q,cs,ss);

    MM = M * M';
    mw = M * weight;
    w = pcg(MM,mw,1e-2,30);
    %sum(w)
    odf = ODF(S3G,w./sum(w),psi,cs,ss);
    
end

% store method
odf = set_option(odf,method);
