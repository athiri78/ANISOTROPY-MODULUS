%% The Piezoelectricity Tensor
% how to work with piezoelectricity
%% 
% This m-file mainly demonstrates how to illustrate the directional
% magnitude of a tensor with mtex
%
%% Open in Editor
%
%% Contents
%
%%
% at first, let us import some piezo electric contants for a quartz
% specimen.

CS = symmetry('-3m', [4.916 4.916 5.4054], 'X||a*', 'Z||c', 'mineral', 'Quartz');

fname = fullfile(mtexDataPath,'tensor', 'Single_RH_quartz_poly.P');

P = loadTensor(fname,CS,'propertyname','piecoelectricity','unit','C/N','interface','P','DoubleConvention')

%% Plotting the magnitude surface
% The default plot of the magnitude, which indicates, in which direction we
% have the most polarisation. By default, we restrict ourselfs to the
% unique region implied by crystal symmetry

plot(P)

%%
% but also, we can plot the whole crystal behavior

plot(P,'complete','smooth')

%%
% Most often, the polarisation is illustrated as surface magnitude

plot(P,'3d')

%%
% Note, that for directions of negative polarisation the surface is mapped
% onto the axis of positive, which then let the surface appears as a double
% coverage

%%
% Quite famous example in various standard litrature is a section thourgh
% the surface, because it can easily be described as an analytical
% solution. We just specify the plane normal vector

plot(P,'section',zvector)

%%
% so we are plotting the polarisation in the xy-plane, or the yz-plane with

plot(P,'section',xvector)

%% Mean Tensor Calculation 
% Let us import some data, which was original published by Mainprice, D.,
% Lloyd, G.E. and Casey , M. (1993) Individual orientation measurements in
% quartz polycrystals: advantages and limitations for texture and
% petrophysical property determinations. J. of Structural Geology, 15,
% pp.1169-1187
%

fname = fullfile(mtexDataPath,'tensor', 'Tongue_Quartzite_Bunge_Euler');

ebsd = loadEBSD(fname,CS,'interface','generic' ...
  , 'ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3'}, 'Bunge', 'active rotation')

%%
% The figure on p.1184 of the publication

Pm = calcTensor(ebsd,P)

plot(Pm)
colorbar

%%
%

plot(Pm,'north','south')
colorbar
