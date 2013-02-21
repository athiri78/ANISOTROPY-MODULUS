%% Plotting Individual Orientations
% Basics to the plot types for individual orientations data
%
%% Open in Editor
%
%% 
% This sections gives an overview over the possibilities that MTEX offers to
% visualize orientation data.
%
%% Contents
%

%%
% Let us first import some EBSD data with a [[matlab:edit mtexdata, script file]]

mtexdata aachen

%%
% and select all individual orientations of the Iron phase

o = get(ebsd('Fe'),'orientations')


%% Scatter Pole Figure Plot
% A pole figure showing scattered points of these data figure can be
% produced by the command <orientation.plotpdf.html plotpdf>.

plotpdf(o,Miller(1,0,0))


%% Scatter (Inverse) Pole Figure Plot
% Accordingly, scatter points in inverse pole figures are produced by the
% command  <orientation.plotpdf.html plotipdf>.

plotipdf(o,xvector)


%% Scatter Plot in ODF Sections
% The plotting og scatter points in sections of the orientation space is carried out by the
% command <orientation.plotodf.html plotodf>. In the above examples the number
% of plotted orientations was chosen automatically such that the
% plots not to become too crowed with points. The number of randomly chosen orientations
% can be specified by the option *points*.

plotodf(o,'points',1000,'sigma')


%% Scatter Plot in Axis Angle or Rodrigues Space
% Another possibility is to plot the single orientations directly into the
% orientation space, i.e., either in axis/angle parameterization or in Rodrigues
% parameterization.

scatter(o,'center',idquaternion)

%%
% Here, the optional option 'center' specifies the center of the unique
% region in the orientation space.


%% Orientation plots for EBSD and grains
% Since EBSD and grain data involves single orientations, the above plotting
% commands are also applicable for those objects.

%%
% Let us consider some grains [[EBSD.calcGrains.html,detected]] from the
% EBSD data

grains = calcGrains(ebsd);

%%
% Then the scatter plot of the individual orientations of the Iron phase in
% the inverse pole figure is achieved by

plotipdf(ebsd('Fe'),xvector,'points',1000, 'MarkerSize',3);

%%
% In the same way the mean orientations of grains can be visualized

plotipdf(grains('Fe'),xvector,'points',500, 'MarkerSize',3);

%%
% Once can also use different colors on the scatter points by certain [[EBSD.get.html,EBSD
% properties]] or [[GrainSet.get.html,grain properties]]

plotpdf(ebsd('Fe'),[Miller(1,0,0),Miller(1,1,0)],'antipodal','MarkerSize',4,...
  'property','mad')

%%
% or some arbitrary data vector

plotodf(grains('Fe'),'antipodal','sections',9,'MarkerSize',3,...
  'property',shapefactor(grains('Fe')),'sigma');

%% 
% Superposition of two scatter plots is achieved by the commands *hold on*
% and *hold off*.

plotipdf(ebsd('Fe'),xvector,'MarkerSize',5,'points',100)
hold on
plotipdf(ebsd('Mg'),xvector,'MarkerSize',5,'points',100,'MarkerColor','r')
hold off

%%
% See also <PlotTypes_demo.html#5, Scatter plots> for more information
% about scatter plot and <SphericalProjection_demo.html,spherical
% projections>  for more information on spherical projections.
