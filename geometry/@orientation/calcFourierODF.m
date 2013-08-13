function odf = calcFourierODF(ori,varargin)
% calculate ODF from individuel orientations via kernel density estimation
%
% *calcODF* is one of the core function of the MTEX toolbox.
% It estimates an ODF from a set of individual crystal orientations by
% [[EBSD2odf.html kernel,density estimation]].
%
% The function *calcODF* has several options to control the halfwidth of
% the kernel functions, the resolution, etc. Most important the estimated
% ODF is affected by the *halfwidth* of the kernel function.
%
% If the halfwidth is large the estimated ODF is smooth whereas a small halfwidth
% results in a sharp ODF. It depends on your prior information about the
% ODF to choose this parameter right. Look at this
% [[EBSDSimulation_demo.html, description]] for exhausive discussion.
%
% Syntax
% calcODF(ori,...,param,var,...)
% calcODF(ebsd,...,param,var,...)
%
% Input
%  ori  - @orientation
%  ebsd - @EBSD
%
% Output
%  odf - @ODF
%
% Options
%  halfwidth - halfwidth of the kernel function
%  kernel    - kernel function (default -- de la Valee Poussin kernel)
%  bandwidth - order up to which Fourier coefficients are calculated
%
% See also
% ebsd_demo EBSD2odf EBSDSimulation_demo loadEBSD ODF/calcEBSD EBSD/calcKernel kernel/kernel

% maybe there is nothing to do
if isempty(ori), odf = ODF; return, end

% construct an exact kernel ODF
odf = calcKernelODF(ori,varargin{:},'exact');

% get bandwidth
L = get_option(varargin,{'L','HarmonicDegree'},min(max(10,bandwidth(k)),max_coef),'double');

% check kernel has at most the requested bandwidth
if bandwidth(odf.psi) > L,
  warning('MTEX:EBSD:calcODF',['Estimation of ODF might become vaque,' ...
    'since Fourier Coefficents of higher order than ', num2str(L),...
      ' are not considered; increasing the kernel halfwidth might help.'])
end

odf = FourierODF(odf,get_option(varargin,{'L','bandwidth','fourier'},L,'double'));

