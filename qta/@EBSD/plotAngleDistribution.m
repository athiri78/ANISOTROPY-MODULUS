function plotAngleDistribution( ebsd, varargin )
% plot the angle distribution
%
%% Input
% ebsd - @EBSD
%
%% Flags
%
%  ODF, MDF     - compute the uncorrelated angle distribution from the MDF
%  uncorrelated - compute the uncorrelated angle distribution from the EBSD
%  data
%
%% See also
% EBSD/calcAngleDistribution
%

if nargin>1 && isscalar(varargin{1})
  bins =  varargin{1};
else
  bins = 20;
end

varargin = set_default_option(varargin,...
  getpref('mtex','defaultPlotOptions'));

%% make new plot
newMTEXplot;

%% get phases

ind = cellfun(@(c) isa(c,'EBSD'),varargin);
if any(ind)
  ebsd2 = varargin{find(ind,1)};
else
  ebsd2 = ebsd;
end

phases1 = get(ebsd,'phase');
ph1 = unique(phases1(phases1>0));

phases2 = get(ebsd2,'phase');
ph2 = unique(phases2(phases2>0));

ph = unique([ph1,ph2]);
for j = 1:numel(ph)
  if ismember(ph(j),ph1)
    obj{ph(j)} = subsref(ebsd,phases1 == ph(j)); %#ok<AGROW>
  else
    obj{ph(j)} = subsref(ebsd2,phases2 == ph(j)); %#ok<AGROW>
  end
  mineral{ph(j)} = get(obj{ph(j)},'mineral'); %#ok<AGROW>
  if check_option(varargin,{'ODF','MDF'})
    obj{ph(j)} = calcODF(obj{ph(j)},'Fourier','halfwidth',10*degree,varargin{:}); %#ok<AGROW>
  end
end

% all combinations of phases
[ph1,ph2] = meshgrid(ph1,ph2);
ph1 = ph1(tril(ones(size(ph1)))>0);
ph2 = ph2(tril(ones(size(ph2)))>0);

%% compute omega

CS = get(ebsd,'CSCell');
phMap = get(ebsd,'phaseMap');
maxomega = 0;

for j = 1:length(CS)
  if isa(CS{j},'symmetry') && any(ph == phMap(j))
    maxomega = max(maxomega,get(CS{j},'maxOmega'));
  end
end



if check_option(varargin,{'ODF','MDF'})
  omega = linspace(0,maxomega,bins);
else
  omega = linspace(0,maxomega,bins);
end

%% compute angle distributions

f = zeros(numel(omega),numel(ph1));

for i = 1:numel(ph1)

  f(:,i) = calcAngleDistribution(obj{ph1(i)},obj{ph2(i)},'omega',omega,varargin{:});
  f(:,i) = 100*f(:,i) ./ sum(f(:,i));

  lg{i} = [mineral{ph1(i)} ' - ' mineral{ph2(i)}]; %#ok<AGROW>
end

%% plot

if check_option(varargin,{'ODF','MDF'})

  p = findobj(gca,'Type','patch');

  if ~isempty(p)
    faktor = size(f,1) / size(get(p(1),'faces'),1);
  else
    faktor = size(f,1);
  end

  optiondraw(plot(omega/degree,faktor * max(0,f)),'LineWidth',2,varargin{:});
else
  optiondraw(bar(omega/degree,f),'BarWidth',1.5,varargin{:});
end

xlabel('misorientation angle in degree')
xlim([0,max(omega)/degree])
ylabel('percent')

legend(lg{:},'Location','northwest')
