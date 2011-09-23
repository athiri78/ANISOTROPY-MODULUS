function [m,ori]= max(odf,varargin)
% heuristic to find local modal orientations
%
%% Input
%  odf - @ODF 
%
%% Output
%  m   - maximum in multiples of the uniform ODF
%  ori - @orientation where the maximum is atained
%
%% Options
%  resolution  - search--grid resolution
%  accuracy    - in radians
%
%% Example
%  find the local maxima of the [[SantaFe.html,SantaFe]] ODF
%
%    [m,ori] = max(SantaFe)
%    plotpdf(SantaFe,Miller(0,0,1))
%    annotate(ori)
%
%
%% See also
% ODF/modalorientation

ori = localModes(odf,varargin{:});

m = eval(odf,ori); %#ok<EVLC>
