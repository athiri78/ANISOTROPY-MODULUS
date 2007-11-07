function spf = simulatePoleFigure(pf,odf,varargin)
% simulate pole figure
%
%% Syntax
% pf = simulatePoleFigure(pf,odf,varargin)
%
%% Input
%  pf  - meassured @PoleFigure
%  odf - @ODF
%
%% Output
% spf - PoleFigure 
%
%% See also
% ODF/simulatePoleFigure

progress(0,length(pf));
for i = 1:length(pf)
    
  spf(i) = simulatePoleFigure(odf,pf(i).h,pf(i).r,...
    'superposition',pf(i).c,varargin{:});
  progress(i,length(pf));
  
end
