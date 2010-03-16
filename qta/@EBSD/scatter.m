function scatter(ebsd,varargin)
% plots ebsd data as scatter plot
%
%% Syntax
% scatter(ebsd,<options>)
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  AXISANGLE     - axis angle projection
%  RODRIGUES     - rodrigues parameterization
%  POINTS        - number of orientations to be plotted
%  CENTER        - orientation center
%
%% See also
% EBSD/plotpdf savefigure

[o ind] = get(ebsd,'orientations','CheckPhase',varargin{:});

varargin = set_option_property(ebsd(ind),varargin{:});

scatter(o,...
  'FigureTitle',[inputname(1) ' (' get(ebsd,'comment') ')'],varargin{:});