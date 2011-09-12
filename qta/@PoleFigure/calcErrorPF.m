function pf = calcErrorPF(pfmeas,pfcalc,varargin)
% error polefigure between meassured and recalculated pole figures
%
% returns a @PoleFigure with valuess given as the difference between the
% meassured intensities and the recalculated @ODF or between two meassured
% @PoleFigure.
%
%% Syntax
% pf = calcErrorPF(pfmeas,pfcalc,<options>) -
% pf = calcErrorPF(pfmeas,odf,<options>)    -
%
%% Input
%  pfmeas - meassured @PoleFigure 
%  pfcalc - recalculated @PoleFigure
%  odf    - recalculated @ODF
%
%% Options
%  RP    - RP value (default)
%  l1    - l1 error
%  l2    - l2 error
%
%% Output
%  pf - @PoleFigure 
%
%% See also
%  PoleFigure/calcError ODF/calcPoleFigure

progress(0,length(pfmeas));
for i = 1:length(pfmeas)
  
  % evaluate ODF if neccesary
  if isa(pfcalc,'ODF')
    pf(i) = calcPoleFigure(pfcalc,pfmeas(i).h,pfmeas(i).r,'superposition',pfmeas(i).c); %#ok<AGROW>
  else
    pf(i) = pfcalc(i); %#ok<AGROW>
  end
  
  % normalization
  alpha = calcNormalization(pfmeas(i),pf(i));
  
  d1 = getdata(pfmeas(i));
  d2 = getdata(pf(i))*alpha;
  
  if check_option(varargin,'l1')    
    d = abs(d1-d2);    
  elseif check_option(varargin,'l2')
    d = (d1-d2).^2;
  elseif check_option(varargin,'RP')
    epsilon = get_option(varargin,'RP',1,'double');
    ind = d2 > epsilon*alpha;
    d = abs(d1(ind)-d2(ind))./d2(ind);
    pf(i).r = delete(pf(i).r,~ind); %#ok<AGROW>
  else
    epsilon = get_option(varargin,'epsilon',1,'double');
    d = abs(d1-d2)./min(d1+epsilon*alpha,d2+epsilon*alpha);
  end
  pf(i).data = d; %#ok<AGROW>
  progress(i,length(pfmeas));
end
