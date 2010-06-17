%% Correct Individual Orientation Data
%
%% Open in Editor
%
%% Abstract
% This script shows how to use MTEX to correct EBSD data for measurement
% errors.
%
%% Contents
%
%%
% Let us first import some standard EBSD data with a [[matlab:edit loadaachen.m, script file]]

loadaachen;

%% 
% and plot the raw data
close all,plot(ebsd)


%% Realign / Rotate the data
%
% Sometimes its required to realign the EBSD data, e.g. by rotating,
% shifting or flipping them. This is done by the commands 
% <EBSD_rotate.html rotate>, <EBSD_fliplr.html fliplr>, <EBSD_flipud.html
% flipud> and <EBSD_shift.html shift>.

% define a rotation
rot = rotation('axis',zvector,'angle',5*degree);

% rotate the EBSD data
ebsd_rot = rotate(ebsd,rot);

% plot the rotated EBSD data
close all, plot(ebsd_rot)

%%
% It should be stressed, that the rotation does not only effect the spatial
% data, i.e. the x, y values, but also the crystal orientations are rotated
% accordingly. This is true as well for the flipping commands
% <EBSD_rotate.html rotate> and <EBSD_fliplr.html fliplr>. Observe, how not
% only the picture is flipped but also the color of the grains chages!

ebsd_flip = flipud(ebsd_rot);
close all, plot( ebsd_flip )


%% Restricting to a region of interest
% If on is not interested in the whole data set but only in those
% measurements inside a certain polygon, the restriction can be
% constructed as follows. Lets start by defining a polygon.


% the polygon
p = polygon([120 130; 120 100; 200 100; 200 130; 120 130]);

% plot the ebsd data
plot(ebsd)

% plot the polygon on top
hold on
plot(p,'color','r','linewidth',2)
hold off


%%
% In order to restrict the ebsd data to the polygon we use the command
% <ebsd_inpolygon.html inpolygon>.

% restrict
ebsd = inpolygon(ebsd,p)

% plot
plot(ebsd)


%% Detecting Inaccurate Orientation Measurements
%
% 
% *By *
%
% In order 

% extract the quantity mad 
mad = get(ebsd,'mad');

% plot a histogram
hist(mad)

%%
% 

ebsd_corrected = delete(ebsd,mad>1)

%%
%
plot(ebsd_corrected)


%% 
% *By grain size*
%
% Sometimes measurements that belongs to grains consisting of only very
% few measurements can be regarded as inaccurate. In order to detect such
% measuremens we have first to reconstruct grains from the EBSD
% measurements using the command <EBSD_segment2d.html segment2d>

[grains,ebsd_corrected] = segment2d(ebsd_corrected,10*degree)

%%
% The histogram of the grainsize shows that there a lot of grains
% consisting only of very few measurements.

hist(grainsize(grains),50)

%%
% Lets find all grains containing at least 5 measurements

large_grains = grains(grainsize(grains) >= 20)

%%
% and remove all orientation measurements not belonging to these grains

ebsd_corrected = link(ebsd_corrected,large_grains)

plot(ebsd_corrected)

%% 
% Now reconstructing again grains in our reduced EBSD data set

[grains_corrected,ebsd_corrected] = segment2d(ebsd_corrected,10*degree)

plot(grains_corrected)

%%
% we observe that there are no very small grains anymore

hist(grainsize(grains_corrected),50)


