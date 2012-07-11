%% Plotting grains and grain boundaries
% Overview about colorizing grains and (special) grain boundaries 
%
%% Open in Editor
%
%% Contents
%

%%
% One of the central issues analizing grains is the visualization by
% spatial maps. Therefor, let us first reconstruct some grains

mtexdata aachen
plotx2east
grains = calcGrains(ebsd,'threshold',2*degree)

%% Plotting grains and combined plots
% The most naive way to plot grains is just

plot(grains)

%%
% Nevertheless, the plot command accepts options as already known from the
% ebsd plot spatial command.

close, plot(grains,'property','phase')

%%
% Particularly one can apply the color coding of orientations, i.e.
% spatially locate the grains with certain orientation.

close, plot(grains,'colorcoding','h',{Miller(1,1,1),[0 0 1]},'r',zvector)

%%
% With the *hold on* command, one can combine several plots, e.g. let us
% take a look at the mad and the phase at the same time. We can control
% transparency with the option *translucent*.

close, plot(ebsd,'property','mad')
colormap(gray)

hold on, plot(grains,'property','phase','translucent',0.4)

%%
% Please note, that the opengl renderer has to be activated to plot grains
% transparent.
%% 
% The reconstructed grains contain the EBSD data, they were reconstructed
% from, thus we select grains of a GrainSet and plot its corresponding EBSD

close, plotspatial(grains(grainSize(grains)>15),'property','bc')

%%
% Also, a property to plot can be given as a Nx1 vector, where N is the
% number of grains.

close, plot(grains,'property',shapefactor(grains))


%% Visualizing grain boundaries
% Plotting grain boundaries may be a usefull task, e.g. marking special
% grain boundaries, generally this is done by the <GrainSet.plotBoundary.html
% plotBoundary> command.

close, plotBoundary(grains)

%%
% A grain boundaries plot can be easily combined with further plots by *hold
% on command, so we can plot various information together

hold on, plot(ebsd,'property','bc')
colormap(gray)

%%
% e.g. we want also to see all one pixel grains

grains_selection = grains( grainSize(grains) == 1) ;

hold on, plotBoundary(grains_selection,'linecolor','r','linewidth',2)

%% Visualizing special grain boundaries
% Most interesting is a closer look at special grain boundaries. This can
% be done by specifing a *property* which should be marked. 
%
%% SUB: Phase boundaries
% For multi-phase system, the location of phase boundaries may be of
% interest.

close,   plot(grains,'translucent',.3)
hold on, plotBoundary(grains,'property','phase','linecolor','r','linewidth',1.5)


%%
% Also, one can encode the combination of phases at the grain boundary. Here, for
% instance we have three types occuring: Fe-Fe, Fe-Mg and Mg-Mg

close, plotBoundary(grains,'property','phasetransition')

%% SUB: Subboundaries
% Another special type of boundaries, are boundaries that are located
% within a grain, nevertheless this happens, if two adjacent measurements
% are somehow conneted by a lattice rotation within a grain.

close,   plotBoundary(grains,'external')
hold on, plotBoundary(grains,'internal','linecolor','r','linewidth',2)

%%
% We also want to see the rotation within the grain.

hold on, plot(grains,'property','mis2mean')

%% SUB: Misorientation
% Basicly there are two ways to visualize misorientation along a grain
% boundary, either to plot the misorientation angle

close, plotBoundary(grains,'property','angle','linewidth',1.5)
colorbar

%%
% or to colorize the misorientation itself between neighboured grains (of the same
% phase)

close,   plotBoundary(grains)
hold on, plotBoundary(grains,'property','misorientation','colorcoding','hkl','r',vector3d(1,1,1),...
  'linewidth',1.5)

%% SUB: Classifing special boundaries
% Actually, it might be more informative, if we classify the grain
% boundaries after some special property. This is done by the command
% <GrainSet.specialBoundary.html specialBoundary>, which will be invoked
% by the plotting routine.
%%
% We can mark grain boundaries after its misorientation angle is in a
% certain range

close, plotBoundary(grains,'linecolor','k')
hold on, plotBoundary(grains,'property',[10 15]*degree,'linecolor','b','linewidth',2)
hold on, plotBoundary(grains,'property',[ 5 10]*degree,'linecolor','g','linewidth',2)
hold on, plotBoundary(grains,'property',[ 2  5]*degree,'linecolor','r','linewidth',2)

legend('>15^\circ',...
  '10^\circ-15^\circ',...
  '5^\circ-10^\circ',...
  '2^\circ-5^\circ')

%%
% Or we mark the rotation axis of the misorientation.

close, plotBoundary(grains)
hold on
plotBoundary(grains,'property',vector3d(1,1,1),'delta',2*degree,...
  'linecolor','b','linewidth',1.5)

legend('>2^\circ',...
  '[111]')

%% 
% Or we mark a special rotation between neighboured grains. If a
% linecolor is not specified, then the boundary is colorcoded after its angular
% difference to the given rotation.

rot = rotation('axis',vector3d(1,1,1),'angle',60*degree);

close,   plotBoundary(grains)
hold on, plotBoundary(grains,'property',rot,'linewidth',1.5)
% hold on, plotBoundary(grains,'property',rot,'linecolor','b','linewidth',1)

legend('>2^\circ',...
  '60^\circ/[001]')
colorbar

%%
% In the same manner, we can classify after predefined special rotations,
% e.g. coincident site lattice (CSL) for cubic crystalls. Additionaly we
% specify a searching radius with the option |'delta'|, in this way, we
% control how far the misorientation of the boundary segment is actuall
% away from the specified rotation.

close ,  plotBoundary(grains,'color','k')
hold on, plotBoundary(grains,'property',CSL(3),'delta',2*degree,...
  'linecolor','b','linewidth',2)
hold on, plotBoundary(grains,'property',CSL(5),'delta',4*degree,...
  'linecolor','m','linewidth',2)
hold on, plotBoundary(grains,'property',CSL(7),'delta',4*degree,...
  'linecolor','g','linewidth',2)
hold on, plotBoundary(grains,'property',CSL(11),'delta',4*degree,...
  'linecolor','r','linewidth',2)

legend('>2^\circ',...
  '\Sigma 3',...
  '\Sigma 5',...
  '\Sigma 7',...
  '\Sigma 11')

%%
% Another kind of special boundaries are tilt and twist boundaries. We can
% find a tilt boundary by specifing the crystal form, which is tilted, i.e.
% the misorientation maps a lattice plane $h$  of on grain onto the others grain
% lattice plane.
% 
% $$ \left( g_1^{-1} * g_2 \right) * h = h, $$
% 
% where $g_1, g_2$ are neighbored orientations.

close, plotBoundary(grains)
hold on, plotBoundary(grains,'property',Miller(1,1,1),'delta',2*degree,...
  'linecolor','r','linewidth',1.5)
hold on, plotBoundary(grains,'property',Miller(0,0,1),'delta',2*degree,...
  'linecolor','b','linewidth',1.5)

legend('>2^\circ',...
  '\{111\}',...
  '\{001\}')

