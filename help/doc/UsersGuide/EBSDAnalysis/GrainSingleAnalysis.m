%% Analyzing Individual Grains
% Explanation how to extract and work with single grains from EBSD data
%
%
%% Open in Editor
%
%% Contents
%
%% Connection between grains and EBSD data
% As usual, let us first import some EBSD data construct some grains

mtexdata aachen
grains = calcGrains(ebsd,'angle',2*degree)

%%
% The <GrainSet_index.html GrainSet> contains the EBSD data it was reconstructed from. We can
% access these data by the <GrainSet.get.html get> command.

grain_selected = grains( grainSize(grains) >=  1160)
ebsd_selected  = get(grain_selected,'EBSD')

%%
% A more convinient way to select grains in daily practice, is by spatial
% coordinates. Note, that the plotting conventions have fairly to be
% adjusted to match the spatial coordinates, present in the EBSD or
% GrainSet.

grain_selected = findByLocation(grains,[145  137])

%%
%

plotBoundary(grain_selected,'linewidth',2)
hold on, plot(ebsd_selected)

%% Visualize the misorientation within a grain
% 

o = get(grain_selected,'mis2mean')
close, plotspatial(grain_selected,'property',angle(o)/degree)
colorbar

%%

close, plotspatial(grain_selected,'property','mis2mean')

%% Testing on Bingham distribution for a single grain
% Although the orientations of an individual grain are highly concentrated,
% they may vary in the shape. In particular, if the grain was deformed by
% some process, we are interessed in quantifications.
%%
% Note, that the |plotpdf|, |plotipdf| and |plotodf| command by default
% only plots the mean orientation of grains. Thus, for these commands, we
% have to explicitely specify the underlaying EBSD data.

close, plotpdf(ebsd_selected,...
  [Miller(0,0,1),Miller(0,1,1),Miller(1,1,1)],'antipodal',...
  'position',[100 100 600 300])

%%
%

close, scatter(grain_selected)

%%
% Testing on the distribution shows a gentle prolatness, nevertheless we
% would reject the hypothesis for some level of significance, since the
% distribution is highly concentrated and the numerical results vague.

[qm,lambda,U,kappa] = mean(grain_selected,'approximated');
num2str(kappa')

%%
%

T_spherical = bingham_test(grain_selected,'spherical','approximated');
T_prolate   = bingham_test(grain_selected,'prolate',  'approximated');
T_oblate    = bingham_test(grain_selected,'oblate',   'approximated');

[T_spherical T_prolate T_oblate]

%% Profiles through a single grain
% Sometimes, grains show large orientation difference when beeing deformed
% and then its of interest, to characterize the lattice rotation. One way
% is to order orientations along certain line segment and look at the
% profile.
%%
% We proceed by specifiing such a line segment

close,   plotBoundary(grain_selected,'linewidth',2)
hold on, plot(ebsd_selected,'property','angle')

% line segment
x =  [154   125.25;
      169.5  134];
line(x(:,1),x(:,2),'linewidth',2)

%%
% The command <EBSD.spatialProfile.html spatialProfile> extracts
% orientations along a line segment

[o,dist] = spatialProfile(ebsd_selected,x);

%%
% where the first output argument is a set of orientations ordered along
% the line segment, and the second is the distance from the starting point.
%% 
% So, we compute misorientation angle and plot as a profile

m = o(1).\o

close, plot(dist,angle(m)/degree)

m = o(1:end-1).\o(2:end)

hold on, plot(dist(1:end-1)+diff(dist)./2,... % shift 
  angle(m)/degree,'color','r')
xlabel('distance'); ylabel('orientation difference in degree')

legend('to reference orientation','to neighbour')

%%
% We can also observe the rotation axis, here we colorize after the
% distance

close, plot(axis(o),'markersize',3,'antipodal','data',dist)





