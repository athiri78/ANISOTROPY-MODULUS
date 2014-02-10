%% Pole Figure Data (The Class @PoleFigure)
% This section describes the class *PoleFigure* and gives an overview over
% the functionality MTEX offers to analyze pole figure data.
% 
%% Contents
%
%% Class Description
%
% The general workflow to deal with pole figure data in MTEX is as follows.
%
% * Import the pole figure data and create an variable of type *PoleFigure* 
% * Visualize the pole figure data
% * Manipulate the pole figure data
% * Compute an ODF from the pole figure data
%
%
%% SUB: Import pole figure data
%
% The most comfortable way to import pole figure data into MTEX is to use
% the import wizard, which can be started by the command

%%
% 
 
import_wizard

%%
% If the data are in a format supported by MTEX the import wizard generates
% a script which imports the data. More information about the import wizard
% and a list of supported file formats can be found
% [[ImportPoleFigureData.html,here]]. A typical script generated by the import 
% wizard looks a follows.

% specify scrystal and specimen symmetry
cs = symmetry('-3m',[1.4,1.4,1.5]);
ss = symmetry('triclinic');

% specify file names
fname = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-22)_amp.cnv')};

% specify crystal directions
h = {Miller(1,0,-1,0,cs),[Miller(0,1,-1,1,cs),Miller(1,0,-1,1,cs)],Miller(1,1,-2,2,cs)};

% specify structure coefficients
c = {1,[0.52 ,1.23],1};

% import pole figure data
pf = loadPoleFigure(fname,h,cs,ss,'superposition',c)

% After running the script the variable *pf* is created which contains all
% information about the pole figure data. 

%% SUB: Plot pole figure data
%
% Pole figures are plotted using the [[PoleFigure.plot.html,plot]] command.
% It plottes a singe colored dot for any data point contained in the pole
% figure. There are many options to specify the way pole figures are
% plotted in MTEX. Have a look at the <Plotting.html plotting section> for
% more informations.

figure
plot(pf,'position',[100 100 600 300])

%% SUB: Manipulate pole digure data
%
% MTEX offers a large collection of operations to analyze and manipulate pole 
% figure data, e.g.
%
% * rotate pole figures
% * scale pole figures
% * find outliers
% * remove specific measurements
% * superpose pole figures
%
% An exhausive introduction how to modify pole figure data can be found
% <ModifyPoleFigureData.html here>
% As an example, if one wants to set all negative intensities to zero one
% can issue the command

pf = delete(pf,pf.r.rho >= 74*degree & pf.r.rho <= 81*degree);
plot(pf)


%% SUB: Calculate an ODF from pole digure data
%
% Calculating an ODF from pole figure data can be done using the command
% <PoleFigure.calcODF.html calcODF>. A precise decription of the underlying
% algortihm as well as of the options can be found 
% <PoleFigure2odf.html here>

odf = calcODF(pf,'zero_range','silent')
plotpdf(odf,h,'superposition',c,...
  'antipodal','position',[100 100 800 300])


%% SUB: Simulate pole figure data
%
% Simulating pole figure data from a given ODF has been proven to be
% usefull to analyze the stability of the ODF estimation process. There is
% an <PoleFigureSimulation_demo.html example> demostrating how to determine the
% number of pole figures to estimate the ODF up to a given error. The MTEX
% command to simulate pole figure is <ODF.calcPoleFigure.html
% calcPoleFigure>, e.g.

pf = calcPoleFigure(SantaFe,Miller(1,0,0),regularS2Grid)
plot(pf)
