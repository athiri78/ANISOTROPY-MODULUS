function plotAngleDistribution(odf,varargin)
% plot axis distribution
%
%% Input
%  odf - @ODF
%
%% Options
%  RESOLUTION - resolution of the plots
%


varargin = set_default_option(varargin,...
  getpref('mtex','defaultPlotOptions'));

%% make new plot
newMTEXplot;

%%
[f,omega] = calcAngleDistribution(odf,varargin{:});


%% plot
%bar(omega/degree,max(0,f));
% xlim([0,max(omega)])

p = findobj(gca,'Type','patch');

if ~isempty(p)
  faktor = 100 / mean(f) / size(get(p(1),'faces'),1);
else
  faktor = 1;
end

  optiondraw(plot(omega/degree,faktor * max(0,f)),'LineWidth',2,varargin{:});

optionplot(omega/degree,faktor * max(0,f),varargin{:});
xlabel('orientation angle in degree')
