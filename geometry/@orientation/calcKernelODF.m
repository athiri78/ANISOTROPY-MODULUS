function odf = calcKernelODF(ori,varargin)
% calculate ODF from individuel orientations via kernel density estimation
%
% *calcKernelODF* is one of the core function of the MTEX toolbox.
% It estimates an ODF from a set of individual crystal orientations by
% [[EBSD2odf.html kernel,density estimation]].
%
% The function *calcKernelODF* has several options to control the halfwidth of
% the kernel functions, the resolution, etc. Most important the estimated
% ODF is affected by the *halfwidth* of the kernel function.
%
% If the halfwidth is large the estimated ODF is smooth whereas a small halfwidth
% results in a sharp ODF. It depends on your prior information about the
% ODF to choose this parameter right. Look at this
% [[EBSDSimulation_demo.html, description]] for exhausive discussion.
%
% Syntax
%   calcODF(ori,...,param,var,...)
%   calcODF(ebsd,...,param,var,...)
%
% Input
%  ori  - @orientation
%  ebsd - @EBSD
%
% Output
%  odf - @ODF
%
% Options
%  HALFWIDTH        - halfwidth of the kernel function
%  RESOLUTION       - resolution of the grid where the ODF is approximated
%  KERNEL           - kernel function (default -- de la Valee Poussin kernel)
%
% Flags
%  EXACT            - no approximation to a corser grid
%
% See also
% ebsd_demo EBSD2odf EBSDSimulation_demo loadEBSD ODF/calcEBSD EBSD/calcKernel kernel/kernel

% maybe there is nothing to do
if isempty(ori), odf = ODF; return, end

% extract weights
if check_option(varargin,'weight')
  weight = get_option(varargin,'weight');
else
  weight = ones(1,length(ori));
end
weight = weight ./ sum(weight(:));

% construct kernel
k = getKernel(ori,varargin{:});
hw = gethw(k);

if check_option(varargin,'exact')
  
  % set up exact ODF
  odf = unimodalODF(ori,k,ori.CS,ori.SS,'weights',weight);
  
else
  
  % define a indexed grid
  res = get_option(varargin,'resolution',max(0.75*degree,hw / 2));
  S3G = equispacedSO3Grid(ori.CS,ori.SS,'resolution',res);

  % construct a sparse matrix showing the relatation between noth grids
  M = sparse(1:length(ori),find(ori,S3G),weight,length(ori),length(S3G));

  % compute weights
  weight = full(sum(M));
  weight = weight ./ sum(weight);

  % eliminate spare rotations in grid
  S3G = subGrid(S3G,weight~=0);
  weight = weight(weight~=0);
  
  % set up approximated ODF
  odf = unimodalODF(S3G,k,ori.CS,ori.SS,'weights',weight);
end
  
end

% ----------------------------------------------------------
function k = getKernel(ori,varargin)
    
% get halfwidth and kernel
if check_option(varargin,'kernel')
  k = get_option(varargin,'kernel');
elseif check_option(varargin,'halfwidth','double')
  k = kernel('de la Vallee Poussin',varargin{:});
else
  
  if ~check_option(varargin,'spatialDependent')
    kappa = (length(ori.CS) * length(ori.SS) * length(ori))^(2/7) * 3; % magic rule
    k = kernel('de la Vallee Poussin',kappa,varargin{:});
  else
    k = kernel('de la Vallee Poussin','halfwidth',10*degree,varargin{:});
  end
  
end
end

